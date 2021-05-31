require 'xgt/ruby'

def get_account_history(address)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {
    account: address
  }
  response = rpc.call('account_history_api.get_account_history', payload)

  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
  response
end

get_account_history('XGT22auyHoY4yZPU')
