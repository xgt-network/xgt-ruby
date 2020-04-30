require 'xgt/ruby'

def find_withdraw_vesting_routes(routes)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {'start' => [], 'limit' => 1, 'order' => 'by_withdraw_route'}
  response = rpc.call('database_api.find_withdraw_vesting_routes', payload)
  
  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
end

find_withdraw_vesting_routes('')
