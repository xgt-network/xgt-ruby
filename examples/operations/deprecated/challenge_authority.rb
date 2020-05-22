require 'xgt/ruby'

def challenge_authority  
rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  wif = ENV["WIF"] || '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
  config = rpc.call('database_api.get_config', {})
  address_prefix = config['XGT_ADDRESS_PREFIX']
  chain_id = config["XGT_CHAIN_ID"]

  txn = {
    "extensions": [],
    "operations": [
      [
        "challenge_authority",
          {
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

challenge_authority
