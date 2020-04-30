require 'xgt/ruby'
load 'dummy_code.rb'

def get_transaction_hex(transaction)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  wif = '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
  config = rpc.call('database_api.get_config', {})
  chain_id = config["XGT_CHAIN_ID"]

  signed = Xgt::Ruby::Auth.sign_transaction(rpc, transaction, [wif], chain_id)
  hex_dump = rpc.call('network_broadcast_api.get_transaction_hex', [transaction])
  
  puts JSON.pretty_generate(hex_dump)
end

get_transaction_hex(Dummy_code.account_create())
