require 'xgt/ruby'

def get_transaction(tx_id)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {
    'tx_id' => tx_id
  }
  rpc.call('account_history_api.get_transaction', payload)
end

tx = get_transaction('ea1cafea3fa745e28140ec05849355b21c9af519')
puts JSON.pretty_generate(tx)
