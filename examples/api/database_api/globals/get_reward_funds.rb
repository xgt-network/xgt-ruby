require 'xgt/ruby'

def get_reward_funds
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {}
  response = rpc.call('database_api.get_reward_funds', payload)
  
  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
  response
end

get_reward_funds
