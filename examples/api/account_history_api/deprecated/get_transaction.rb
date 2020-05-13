require 'xgt/ruby'

def get_transaction(tx_id)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {
    'tx_id' => tx_id
  }
  rpc.call('account_history_api.get_transaction', payload)
end

tx = get_transaction('535268f92daf01be6bfdeb79be5ef67bc6210a30')
puts JSON.pretty_generate(tx)
