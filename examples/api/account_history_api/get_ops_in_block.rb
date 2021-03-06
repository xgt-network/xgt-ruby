require 'xgt/ruby'

def get_ops_in_block(block_num)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {
    block_num: block_num,
    only_virtual: false
  }
  response = rpc.call('account_history_api.get_ops_in_block', payload)
  
  puts JSON.pretty_generate(payload)
  puts "\n\n"
  puts JSON.pretty_generate(response) 
  response 
end

get_ops_in_block('234')
