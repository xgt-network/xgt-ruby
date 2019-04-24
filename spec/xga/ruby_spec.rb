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

  describe Xga::Ruby::Auth do
    it 'signs a transaction' do
      fixture = JSON.load(File.open('spec/fixtures/condenser-api-get-transaction-hex-response.json'))
      wifs = ['5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n']
      address_prefix = 'TST'
      chain_id = '18dcf0a285365fc58b71f18b3d3fec954aa0c141c44e4e5cb4cf777b9eab274e'
      txn = {
        'expiration' => '2019-04-23T20:58:33',
        'extensions' => [],
        'operations' => [
          [
            'account_create',
            {
              'fee' => '0.000 TESTS',
              'creator' => 'initminer',
              'new_account_name' => 'foo41700a44',
              'owner' => {
                'weight_threshold' => 1,
                'account_auths' => [],
                'key_auths' => [
                  [
                    'TST7xue5ESY1xHhDZj6dw2igXCwoHobA3cnxffacvp4XMzwfzLZu4',
                    1
                  ]
                ]
              },
              'active' => {
                'weight_threshold' => 1,
                'account_auths' => [],
                'key_auths' => [
                  [
                    'TST6Yp3zeaYNU7XJF2MxoHhDcWT4vGgVkzTLEvhMY6g5tvmwzn3tN',
                    1
                  ]
                ]
              },
              'posting' => {
                'weight_threshold' => 1,
                'account_auths' => [],
                'key_auths' => [
                  [
                    'TST5Q7ZdopjQWZMwiyZk11W5Yhvsfu1PG3f4qsQN58A7XfHP34Hig',
                    1
                  ]
                ]
              },
              'memo_key' => 'TST5u69JnHZ3oznnwn71J6VA4r5oVJX6Xu3dpbFVoHpJoZXnbDfaW',
              'json_metadata' => '',
              'extensions' => []
            }
          ]
        ],
        'ref_block_num' => 34960,
        'ref_block_prefix' => 883395518
      }

      expected_transaction_hex = '9088be8ba734797cbf5c01090000000000000000035445535453000009696e69746d696e65720b666f6f343137303061343401000000000103951f1e294b4f9e535708bcfa85d8d21240bda7585424b2e6fa0d0f1e9a756e8c010001000000000102dab63701259352fa01048a97ac76d44def848552518c7991e4bb2feb893e6eef0100010000000001024343ff4fcd3a2ddfbb53fbd178b09ed02c457dbd88d1ff2f49ce967d7c3f5637010002850edf288f0e9fdc4bf83839d352d3b9e65bdefb309147ad3642b4a63e0a6c660000'
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
      result = Xga::Ruby::Auth.sign_transaction(rpc, txn, wifs, address_prefix, chain_id)
      expect(result['operations']).to_not be_nil
      expect(result['operations'].first).to_not be_nil
      expect(result['operations'].first.first).to eq('account_create')
      expect(result['signatures']).to_not be_nil
      expect(result['signatures'].first).to be_a(String)
    end
  end
end
