require 'securerandom'
require 'faraday'
require 'faraday_middleware'
require 'bitcoin'
require 'xga/ruby/version'

module Xga
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
      def self.sign_transaction(rpc, txn, wifs, address_prefix, chain_id)
        response = rpc.call('condenser_api.get_transaction_hex', [txn])
        transaction_hex = response['result'][0..-3]
        digest_hex = Digest::SHA256.hexdigest(unhexlify(chain_id + transaction_hex))
        private_keys = wifs.map { |wif| Bitcoin::Key.from_base58(wif) }
        ec = Bitcoin::OpenSSL_EC
        count = 0
        sig = nil
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
