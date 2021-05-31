require 'xgt/ruby'

def find_witnesses(witnesses)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {
    recoveries: [witnesses],
  }
  response = rpc.call('database_api.find_witnesses', payload)
  
  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
  response
end

find_witnesses('XGT0000000000000')
