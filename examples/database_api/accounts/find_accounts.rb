require 'xgt/ruby'

def find_accounts(wallet_address)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {
    accounts: [wallet_address]
  }
  response = rpc.call('database_api.find_accounts', payload)
  
  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
  response
end

find_accounts('XGT22NqCrWPExii6')
