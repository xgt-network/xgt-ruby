require 'xgt/ruby'
load 'dummy_code.rb'

def broadcast_transaction(signed_transaction)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = [signed_transaction]
  response = rpc.call('network_broadcast_api.broadcast_transaction', payload)  

  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
  # Returns nothing
  response
end

broadcast_transaction(Dummy_code.account_create())
