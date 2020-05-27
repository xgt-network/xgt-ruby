require 'xgt/ruby'

def escrow_approve  
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  wif = '5JANXuPvF1DuhEpf2AKCDhMgaY7ZhYj6qM6HtKUfvnLkuZ6JwGZ'
  wif2 = '5JdgpjVNcAQQhTjhvZgypEQsZqS7nLfPTyURWUgJXze8k65SKiJ'
  wif3 = '5JWufsfFUfKQKwhsYy26oiVifMpyTy3bCkzuL7bcgYpNrCW731s'
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
            "to": "XGT32apWJQf7pVbm",
            "agent": "XGT25svCHdyiRN1C",
            "who": "XGT32apWJQf7pVbm",
            "escrow_id": 59102208,
            "approve": true
          }
      ]
    ]
  }
  
  signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [wif3], chain_id)
  puts JSON.pretty_generate(signed)
  puts "\n\n"
  response = rpc.call('network_broadcast_api.broadcast_transaction_synchronous', [signed])
  puts JSON.pretty_generate(response)
end

escrow_approve
