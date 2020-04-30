require 'xgt/ruby'

def list_recovery_histories()
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = 
    {
      'start' => [],
      'limit' => 1,
    }
  response = rpc.call('database_api.list_recovery_histories', payload)
  
  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
end

list_recovery_histories()
