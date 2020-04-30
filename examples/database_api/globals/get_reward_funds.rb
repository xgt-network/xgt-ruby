require 'xgt/ruby'

def get_reward_funds()
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  reward_funds = rpc.call('database_api.get_reward_funds', {})
  puts JSON.pretty_generate(reward_funds)
end

get_reward_funds()
