require 'xgt/ruby'

def list_witnesses
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {
    start: 0,
    limit: 1,
    order: "by_name"
  }
  response = rpc.call('database_api.list_witnesses', payload)
  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
  response
end

list_witnesses
