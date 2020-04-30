require 'xgt/ruby'

def list_witnesses()
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = 
    {"limit" => 1, "order" => "by_name" }
  witnesses = rpc.call('database_api.list_witnesses', payload)
  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(witnesses)
end

list_witnesses()
