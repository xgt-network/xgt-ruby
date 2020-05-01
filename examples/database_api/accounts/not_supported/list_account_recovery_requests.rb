require 'xgt/ruby'

def list_account_recovery_requests
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {
    start: '',
    limit: 1,
    order: 'by_account'
  }
  response = rpc.call('database_api.list_account_recovery_requests', payload)

  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
  response
end

list_account_recovery_requests
