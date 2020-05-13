require 'xgt/ruby'

def enum_virtual_ops(block_begin, block_end)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {
    'block_range_begin' => block_begin,
    'block_range_end' => block_end
  }
  rpc.call('account_history_api.enum_virtual_ops', payload)
end

ops = enum_virtual_ops('1', '500')

puts JSON.pretty_generate(ops)

