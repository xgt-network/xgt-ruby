require 'xgt/ruby'

def create_proposal  
rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  wif = ENV["WIF"] || '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
  config = rpc.call('database_api.get_config', {})
  address_prefix = config['XGT_ADDRESS_PREFIX']
  chain_id = config["XGT_CHAIN_ID"]
  current_time = Time.now

  txn = {
    "extensions": [],
    "operations": [
      [
        "create_proposal",
          {
            "creator": "XGT0000000000000",
            "receiver": "XGT22axtVs39wpg9",
            "start_date": "2020-05-23T09:00:00",
            "end_date": "2020-05-24T09:00:00",
            "daily_pay": "3000.000 SBD",
            "amount": 3000,
            "precision": 3,
            "nai": "@@000000013",
            "subject": "subject",
            "permlink": "http://test.host"
          }
      ]
    ]
  }
  
  signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [wif], chain_id)
  puts JSON.pretty_generate(signed)
  puts "\n\n"
  response = rpc.call('network_broadcast_api.broadcast_transaction_synchronous', [signed])
  puts JSON.pretty_generate(response)
end

create_proposal
