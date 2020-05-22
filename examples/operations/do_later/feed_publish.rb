require 'xgt/ruby'

def feed_publish  
rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  wif = '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
  config = rpc.call('database_api.get_config', {})
  address_prefix = config['XGT_ADDRESS_PREFIX']
  chain_id = config["XGT_CHAIN_ID"]

  txn = {
    "extensions": [],
    "operations": [
      [
        "feed_publish",
          {
            "publisher": "XGT0000000000000",
            "exchange_rate": {
              #"base": {
                "amount": 0.000,
                "precision": 3,
                "nai": "@@000000013",
              #},
              #"quote": {
                "amount": 100.000,
                "precision": 3,
                "nai": "@@000000021",
              #}
            }
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

feed_publish
