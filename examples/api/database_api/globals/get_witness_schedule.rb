require 'xgt/ruby'

def get_witness_schedule
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {}
  response = rpc.call('database_api.get_witness_schedule', payload)

  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
  response
end

get_witness_schedule
