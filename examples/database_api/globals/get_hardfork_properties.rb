require 'xgt/ruby'

def get_hardfork_properties
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {}
  response = rpc.call('database_api.get_hardfork_properties', payload)
  
  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
  response
end

get_hardfork_properties
