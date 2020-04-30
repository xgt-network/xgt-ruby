require 'xgt/ruby'
load 'dummy_code.rb'

def push_transaction(signed_transaction)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  wif = '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
  config = rpc.call('database_api.get_config', {})
  chain_id = config["XGT_CHAIN_ID"]

  tx = rpc.call('chain_api.push_transaction', [signed_transaction])
  
  puts JSON.pretty_generate(tx)
end

push_transaction(Dummy_code.account_create())



