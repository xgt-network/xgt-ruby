require 'xgt/ruby'

def list_escrows
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {
    start: ["XGT0000000000000", 0],
    limit: 1,
    order: 'by_from_id'
  }
  response = rpc.call('database_api.list_escrows', payload) 
  
  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
  response
end

list_escrows
