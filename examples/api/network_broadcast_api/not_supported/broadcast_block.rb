require 'xgt/ruby'
load 'dummy_code.rb'

def broadcast_block(signed_block)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {
    signed_block: signed_block
  }
  response = rpc.call('network_broadcast_api.broadcast_block', payload)
  
  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
  response
end

broadcast_block('0')
