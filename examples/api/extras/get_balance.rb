require 'xgt/ruby'

def get_balance(name)

 rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  config = rpc.call('database_api.get_config', {})
  chain_id = config['XGT_CHAIN_ID']
  witness_schedule = rpc.call('database_api.get_witness_schedule', {}) || {}
  chain_properties = witness_schedule['median_props']
  fee = chain_properties['account_creation_fee'] || {}
  amount = fee['amount'].to_f * 0.001
  creation_fee = "#{'%0.3f' % amount} XGT"
  currency_symbol = creation_fee.split(/\s+/).last
  account = rpc.call('database_api.find_accounts', { 'accounts' => [name] })

  raw_balance = account['accounts'].first['balance']['amount'].to_i
  balance = '%.3f' % (raw_balance * 0.001)
  string_balance = %(#{balance} #{currency_symbol})
  
  puts JSON.pretty_generate(string_balance)
  puts "\n\n"
  puts JSON.pretty_generate(account)
  account

end

get_balance('XGT2xtVNz7nxdDp6')
