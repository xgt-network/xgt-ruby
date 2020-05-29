require 'xgt/ruby'

def account_witness_vote  
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  money_private = '5Kgsi9os8SG8kdg3ZVb4gjWnZhXYb4xLoYFEkQEWLkzodahY2dn'
  config = rpc.call('database_api.get_config', {})
  address_prefix = config['XGT_ADDRESS_PREFIX']
  chain_id = config["XGT_CHAIN_ID"]

  txn = {
    "extensions": [],
    "operations": [
      [
        "account_witness_vote",
        {
          "account": "XGT28Ab1ezDunt2g",
          "witness": "XGT0000000000000",
          "approve": true
        }
      ]
    ]
  }
  
  signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [money_private], chain_id)
  puts JSON.pretty_generate(signed)
  puts "\n\n"
  response = rpc.call('network_broadcast_api.broadcast_transaction_synchronous', [signed])
  puts JSON.pretty_generate(response)
end

account_witness_vote
