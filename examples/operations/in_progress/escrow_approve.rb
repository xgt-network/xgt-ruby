require 'xgt/ruby'

def escrow_approve  
rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  wif = '5JVyymkQmYXspazYdsjfNtdQ8tnJfCruA2v43cS3VdwcsKjo5a8'
  config = rpc.call('database_api.get_config', {})
  address_prefix = config['XGT_ADDRESS_PREFIX']
  chain_id = config["XGT_CHAIN_ID"]

  txn = {
    "extensions": [],
    "operations": [
      [
        "escrow_approve",
          {
            "from": "XGT0000000000000",
            "to": "XGT28Ab1ezDunt2g",
            "agent": "XGT22axtVs39wpg9",
            "who": "XGT22axtVs39wpg9",
            "escrow_id": 59102208,
            "approve": true
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

escrow_approve
