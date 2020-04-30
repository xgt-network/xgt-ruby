require 'xgt/ruby'

def get_version()
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  wif = '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
  output = rpc.call('database_api.get_version', {})
  puts JSON.pretty_generate(output)
  
end

get_version()

