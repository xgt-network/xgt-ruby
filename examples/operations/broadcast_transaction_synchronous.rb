require 'xgt/ruby'
load 'dummy_code.rb'
load 'account_witness_vote.rb'

def broadcast_transaction_synchronous(signed_transaction)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = [signed_transaction]
  response = rpc.call('network_broadcast_api.broadcast_transaction_synchronous', payload)
  
  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
  response
end

broadcast_transaction_synchronous([Dummy_code.account_create, Account_witness_vote.account_witness_vote])
