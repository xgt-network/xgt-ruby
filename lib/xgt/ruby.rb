require 'securerandom'
require 'faraday'
require 'faraday_middleware'
require 'bitcoin'
require 'time'
require 'xgt/ruby/version'

module Xgt
  module Ruby
    class Error < StandardError; end

    class Rpc
      def initialize(url, client: nil)
        @url = url
        @client = client || Faraday::Connection.new(url: @url) do |faraday|
          faraday.request(:json)
          faraday.response(:json)
          faraday.response(:logger)
          faraday.adapter(Faraday.default_adapter)
        end
      end

      def call(mthd, params)
        id = SecureRandom.hex(6).to_i(16)
        payload = {
          'jsonrpc' => '2.0',
          'method' => mthd,
          'params' => params,
          'id' => id
        }

        response = @client.post('/', payload)
        # TODO: Verify status code
        # TODO: Handle error responses
        response.body
      end
    end

    class Auth
      def self.sign_transaction(rpc, txn, wifs, chain_id)
        # Get the last irreversible block number
        response = rpc.call('database_api.get_dynamic_global_properties', {})
        result = response['result']
        chain_date = result['time'] + 'Z'
        last_irreversible_block_num = result['last_irreversible_block_num']
        ref_block_num = (last_irreversible_block_num - 1) & 0xffff

        # Get ref block info to append to the transaction
        response = rpc.call('block_api.get_block_header', { 'block_num' => last_irreversible_block_num })
        result = response['result']
        header = result['header']
        head_block_id = (header && header['previous']) ? header['previous'] : '0000000000000000000000000000000000000000'
        ref_block_prefix = [head_block_id].pack('H*')[4...8].unpack('V').first
        expiration = (Time.parse(chain_date) + 600).iso8601.gsub(/Z$/, '')

        # Append ref block info to the transaction
        txn['ref_block_num'] = ref_block_num
        txn['ref_block_prefix'] = ref_block_prefix
        txn['expiration'] = expiration

        # Get a hex digest of the transactioon
        response = rpc.call('condenser_api.get_transaction_hex', [txn])
        transaction_hex = response['result'][0..-3]
        digest_hex = Digest::SHA256.hexdigest(unhexlify(chain_id + transaction_hex))
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

      def self.generate_wif(name, password, role, address_prefix)
        brain_key = (name + role + password).strip.split(/[\t\n\v\f\r ]+/).join(' ')
        big_num = OpenSSL::BN.new(Digest::SHA256.hexdigest(brain_key).to_i(16))
        group = OpenSSL::PKey::EC::Group.new('secp256k1')
        product = group.generator.mul(big_num).to_bn
        public_key_buffer = OpenSSL::PKey::EC::Point.new(group, product).to_octet_string(:compressed)
        checksum = Digest::RMD160.digest(public_key_buffer)
        address_prefix + to_base_58(public_key_buffer + checksum[0...4])
      end

      BASE_58_ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'

      def self.to_base_58(bytes)
        alphabet = BASE_58_ALPHABET
        bytes = bytes.unpack('C*')
        return '' if bytes.empty?
        bytes = bytes.dup
        leading_zeroes = 0
        loop do
          break unless leading_zeroes < bytes.length && bytes[leading_zeroes] == 0
          leading_zeroes += 1
        end
        output = ''
        start_at = leading_zeroes
        loop do
          break unless start_at < bytes.length
          mod = div_mod_58(bytes, start_at)
          start_at += 1 if bytes[start_at] == 0
          output = alphabet[mod] + output
        end
        if output.length > 0
          loop do
            break unless output[0] == alphabet[0]
            output = output[1..-1]
          end
        end
        loop do
          break unless leading_zeroes > 0
          leading_zeroes -= 1
          output = alphabet[0] + output
        end
        output
      end

      def self.div_mod_58(number, start_at)
        remaining = 0
        (start_at...number.length).each do |i|
          num = (0xff & remaining) * 256 + number[i]
          number[i] = num / 58
          remaining = num % 58
        end
        remaining
      end

      def self.fixnum_to_der(fixnum, intended_length)
        bytes = Array.new(intended_length, 0)
        (bytes.length - 1).downto(0).each do |i|
          bytes[i] = fixnum & 0xff
          fixnum >>= 8
        end
        bytes.map { |n| [n.chr].pack('h*') }.join('')
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
