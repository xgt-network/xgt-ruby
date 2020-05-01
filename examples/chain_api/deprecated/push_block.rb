require 'xgt/ruby'
load 'dummy_code.rb'

def push_block(signed_transaction)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {
    signed_block: signed_transaction
  }
  response = rpc.call('chain_api.push_block', payload)
  
  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
  response
end

push_block(Dummy_code.account_create())



