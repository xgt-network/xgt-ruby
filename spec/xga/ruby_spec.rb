RSpec.describe Xga::Ruby do
  it 'has a version number' do
    expect(Xga::Ruby::VERSION).not_to be nil
  end

  describe Xga::Ruby::Rpc do
    it 'can make a network request' do
      fixture = JSON.load(File.open('spec/fixtures/database-api-find-accounts-response.json'))
      client = Faraday::Connection.new(url: @url) do |faraday|
        faraday.request(:json)
        faraday.response(:json)
        faraday.adapter(:test) do |stub|
          stub.post('/') do |env|
            [200, {}, JSON.dump(fixture)]
          end
        end
      end
      rpc = Xga::Ruby::Rpc.new('http://test.host', client: client)
      response = rpc.call('database_api.find_accounts', { accounts: ['foo45fb448c'] })
      expect(response['jsonrpc']).to eq('2.0')
      expect(response['id']).to_not be_nil
      expect(response['id']).to eq(fixture['id'])
      expect(response['result']).to_not be_nil
      result = response['result']
      expect(result['accounts']).to_not be_nil
    end
  end
end
