require 'xgt/ruby'

def get_account_history(address)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  rpc.call('account_history_api.get_account_history', {'account' => address })
end

history = get_account_history('XGT29ZZP6RMk9KCT')

puts JSON.pretty_generate(history)
