require 'securerandom'
require 'faraday'
require 'faraday_middleware'
require 'bitcoin'
require 'time'
require 'xgt/ruby/version'

module Xgt
  module Ruby
    class Error < StandardError; end
    class RpcError < Error
      attr_reader :response
      def initialize(msg, response)
        super(msg)
        @response = response
      end
    end

    class Rpc
      def initialize(url, client: nil)
        @url = url
        @client = client || Faraday::Connection.new(url: @url) do |faraday|
          faraday.request(:json)
          faraday.request :retry,
            max: 10,
            interval: 0.05,
            interval_randomness: 0.5,
            backoff_factor: 2,
            # TODO: Make this more specific
            exceptions: ['Error']
          faraday.response(:json)
          faraday.response(:logger) if ENV['LOGGING_ENABLED']
          faraday.adapter(Faraday.default_adapter)
        end
      end

      def call(mthd, params)
        id = SecureRandom.hex(6).to_i(16)
        payload = {
          'jsonrpc' => '2.0',
          'method' => mthd,
          'id' => id
        }
        payload['params'] = params unless params.nil?

        response = @client.post('/', payload)

        # TODO: Verify status code
        unless response.body
          raise RpcError.new(%(No response body!\n#{response.inspect}), response)
        end

        if response.body['error']
          raise RpcError.new(%(Endpoint returned an error response!\n#{JSON.pretty_generate(response.body['error'])}), response)
        end

        unless response.body['result']
          raise RpcError.new(%(No result in response body!\n#{response.inspect}), response)
        end

        # TODO: XXX: Breaking change!
        response.body['result']
      end

      def broadcast_transaction(txn, wifs, chain_id)
        signed = Xgt::Ruby::Auth.sign_transaction(self, txn, wifs, chain_id)
        response = self.call('transaction_api.broadcast_transaction', [signed])
        response['id']
      end

      def transaction_ready?(id)
        begin
          self.call('wallet_history_api.get_transaction', { 'id' => id })
    true
        rescue Xgt::Ruby::RpcError => e
          message = e&.response
                     &.body
                     &.fetch('error', nil)
                     &.fetch('message', nil)
    wait_regexps = Regexp.union('Unknown Transaction', %r(transaction.*?>.*?trx_in_block))
    raise e unless message.match(wait_regexps)
    false
        end
      end
    end

    class Auth
      def self.sign_transaction(rpc, txn, wifs, chain_id)
        # Get the last irreversible block number
        response = rpc.call('database_api.get_dynamic_global_properties', {})
        chain_date = response['time'] + 'Z'
        last_irreversible_block_num = response['last_irreversible_block_num']
        ref_block_num = (last_irreversible_block_num - 1) & 0xffff
        # Get ref block info to append to the transaction
        response = rpc.call('block_api.get_block_header', { 'block_num' => last_irreversible_block_num })
        header = response['header']
        head_block_id = (header && header['previous']) ? header['previous'] : '0000000000000000000000000000000000000000'
        ref_block_prefix = [head_block_id].pack('H*')[4...8].unpack('V').first
        expiration = (Time.parse(chain_date) + 600).iso8601.gsub(/Z$/, '')
        # Append ref block info to the transaction
        txn['ref_block_num'] = ref_block_num
        txn['ref_block_prefix'] = ref_block_prefix
        txn['expiration'] = expiration
        # Get a hex digest of the transactioon
        response = rpc.call('transaction_api.get_transaction_hex', [txn])
        transaction_hex = response[0..-3]
        unhexed = unhexlify(chain_id + transaction_hex)
        digest_hex = Digest::SHA256.hexdigest(unhexed)
        private_keys = wifs.map { |wif| Bitcoin::Key.from_base58(wif) }
        ec = Bitcoin::OpenSSL_EC
        count = 0
        sig = nil

        # Calculate signatures and add them to the transaction
        txn['signatures'] ||= []
        private_keys.each do |private_key|
          loop do
            count += 1
            # TODO: Periodically check that count doesn't spin out of control
            public_key_hex = private_key.pub
            digest = unhexlify(digest_hex)
            sig = ec.sign_compact(digest, private_key.priv, public_key_hex, false)
            next if public_key_hex != ec.recover_compact(digest, sig)
            break if canonical?(sig)
          end
          txn['signatures'] << hexlify(sig)
        end
        txn
      end

      def self.random_wif()
        private_key = unhexlify('80' + SecureRandom.hex(32))
        checksum = Digest::SHA256.digest( Digest::SHA256.digest(private_key) ).byteslice(0, 4)
        to_base_58(private_key + checksum)
      end

      def self.generate_wif(name, password, role)
        brain_key = (name + role + password).strip.split(/[\t\n\v\f\r ]+/).join(' ')
        key = "\x80".b + Digest::SHA256.digest(brain_key)
        checksum = Digest::SHA256.digest(Digest::SHA256.digest(key))[0...4]
        to_base_58(key + checksum)
      end

      def self.wif_to_public_key(wif, address_prefix)
        private_wif = unhexlify(Bitcoin.decode_base58(wif))
        version = private_wif[0]
        checksum = private_wif[-4..-1]
        # TODO: Verify version and checksum
        private_key = private_wif[1...-4]
        big_num = OpenSSL::BN.new(hexlify(private_key).to_i(16))
        group = OpenSSL::PKey::EC::Group.new('secp256k1')
        product = group.generator.mul(big_num).to_bn
        public_key_buffer = OpenSSL::PKey::EC::Point.new(group, product).to_octet_string(:compressed)
        checksum = Digest::RMD160.digest(public_key_buffer)
        address_prefix + to_base_58(public_key_buffer + checksum[0...4])
      end

      def self.to_base_58(bytes)
        Bitcoin.encode_base58(hexlify(bytes))
      end

      def self.from_base_58(string)
        unhexlify(Bitcoin.decode_base58(string))
      end

      def self.hexlify(s)
        a = []
        if s.respond_to?(:each_byte)
          s.each_byte { |b| a << sprintf('%02X', b) }
        else
          s.each { |b| a << sprintf('%02X', b) }
        end
        a.join.downcase
      end

      def self.unhexlify(s)
        s.split.pack('H*')
      end

      def self.canonical?(sig)
        sig = sig.unpack('C*')

        !(
          ((sig[0] & 0x80 ) != 0) || ( sig[0] == 0 ) ||
          ((sig[1] & 0x80 ) != 0) ||
          ((sig[32] & 0x80 ) != 0) || ( sig[32] == 0 ) ||
          ((sig[33] & 0x80 ) != 0)
        )
      end
    end
  end
end
