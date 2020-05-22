require 'xgt/ruby'

def account_witness_proxy  
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  money_private = '5KVfFwjTr3N7JgwbWFrXZq2yijBppemQZdU9e6m7Qn11khsNxqf'
  config = rpc.call('database_api.get_config', {})
  address_prefix = config['XGT_ADDRESS_PREFIX']
  chain_id = config['XGT_CHAIN_ID']

   txn = {
    "extensions": [],
    "operations": [
      [
        "account_witness_proxy",
          {
            "account": "XGT29ZJ2QvhkV4wM",
            "proxy": "XGT0000000000000"
          }
      ]
    ]
  }

  signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [money_private], chain_id)
  puts JSON.pretty_generate(signed)
  response = rpc.call('network_broadcast_api.broadcast_transaction_synchronous', [signed])
  puts JSON.pretty_generate(response)
end

account_witness_proxy
