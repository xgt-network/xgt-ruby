require 'xgt/ruby'

def list_withdraw_vesting_routes()
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = { 'start' => [], 'limit' => 1, 'order' => 'by_withdraw_route' }
  response = rpc.call('database_api.list_withdraw_vesting_routes', payload)

  puts JSON.pretty_generate(payload)
  "\n\n"
  puts JSON.pretty_generate(response)
end

list_withdraw_vesting_routes()
