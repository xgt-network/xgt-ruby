require 'xgt/ruby'

def get_key_references(keys)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {
    keys: [keys]
  }
  response = rpc.call('account_by_key_api.get_key_references', payload)

  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
  response
end

get_key_references('XGT6ZqzbKbQ7MhGZ2GpbP7tz3f4es2r8qmgP88bgBM6JKzWTWYGkH')
