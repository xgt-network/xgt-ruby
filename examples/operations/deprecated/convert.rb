require 'xgt/ruby'

def convert  
rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  wif = '5JxT9NqfjymtBJi4dtrqGqnJvrZg5CiimEbC6YkYJGCV4YA7vQJ'
  config = rpc.call('database_api.get_config', {})
  address_prefix = config['XGT_ADDRESS_PREFIX']
  chain_id = config["XGT_CHAIN_ID"]

  txn = {
    "extensions": [],
    "operations": [
      [
        "convert",
          {
            "owner": "XGT25sPK8vj1o1Go",
            "requestid": 1467592156,
            "amount": "5000.000 XGT",
=begin
            "amount": {
              "amount": "5000",
              "precision": 3,
              "nai": "@@000000013"
            }
=end
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

convert
