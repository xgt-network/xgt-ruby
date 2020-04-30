require 'xgt/ruby'
load 'dummy_code.rb'

def broadcast_block(signed_block)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  wif = '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
  config = rpc.call('database_api.get_config', {})
  chain_id = config["XGT_CHAIN_ID"]

  block = rpc.call('network_broadcast_api.broadcast_block', 'signed_block' => signed_block)
  
  puts JSON.pretty_generate(block)
end

broadcast_block('00000000')
