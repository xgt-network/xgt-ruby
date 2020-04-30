require 'xgt/ruby'

def get_hardfork_properties()
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  hardfork_properties = rpc.call('database_api.get_hardfork_properties', {})
  puts JSON.pretty_generate(hardfork_properties)
end

get_hardfork_properties()
