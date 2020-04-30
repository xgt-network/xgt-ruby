require 'xgt/ruby'

def find_accounts(name)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  account = rpc.call('database_api.find_accounts', {'accounts' => [name] })
  
  puts JSON.pretty_generate(account)
end

find_accounts('XGT23kBBcBgY3g6r')
