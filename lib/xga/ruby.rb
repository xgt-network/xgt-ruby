require 'securerandom'
require 'faraday'
require 'faraday_middleware'
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

    # Your code goes here...
  end
end
