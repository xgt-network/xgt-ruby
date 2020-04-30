require 'xgt/ruby'

def get_witness_schedule()
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  witness_schedule = rpc.call('database_api.get_witness_schedule', {})
  puts JSON.pretty_generate witness_schedule
end

get_witness_schedule()
