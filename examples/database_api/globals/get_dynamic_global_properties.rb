require 'xgt/ruby'

def get_dynamic_global_properties()
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  output = rpc.call('database_api.get_dynamic_global_properties', {})
  
  puts JSON.pretty_generate(output)
end

get_dynamic_global_properties()


