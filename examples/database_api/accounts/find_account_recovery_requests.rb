require 'xgt/ruby'

def find_account_recovery_requests(accounts)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = { 'accounts' => [accounts] }
  response = rpc.call('database_api.find_account_recovery_requests', payload)
  
  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
 end

find_account_recovery_requests('XGT0000000000000') 
