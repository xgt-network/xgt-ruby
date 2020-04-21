require 'xgt/ruby'

def get_key_references(key)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  rpc.call('account_by_key_api.get_key_references', {'keys' => [key] })
end

references = get_key_references('XGT6ejjRv1fDDbe9bbNfx98U9847hvfDzWvFXTriHG2M5xLaWoCu5')

puts JSON.pretty_generate({'keys' => [key] })
puts "\n"
puts JSON.pretty_generate(references)
