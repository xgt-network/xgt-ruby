require 'xgt/ruby'

def get_key_references(keys)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {
    keys: keys
  }
  response = rpc.call('account_by_key_api.get_key_references', payload)

  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response)
  response
end

keys = ['XGT799RiXcTe1kKm1TRiAqaGySaH7oh3J34YYB4h31zw3df3P6ei5', 'XGT74zqjh1D6S8LRjYiHEFdQ228k4qhgoTY1bmEu8BZBUUd5wsL6n'] 

get_key_references(keys)
