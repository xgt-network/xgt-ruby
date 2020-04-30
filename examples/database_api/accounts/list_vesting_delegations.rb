require 'xgt/ruby'

def list_vesting_delegations()
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {'start' => [], 'limit' => 1, 'order' => 'by_delegation'}
  response = rpc.call('database_api.list_vesting_delegations', payload)

  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
end

list_vesting_delegations()
