require 'xgt/ruby'

def find_transaction(tx_id)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  payload = {
    "transaction_id" => tx_id,
    "expiration" => "12:00:00"
  }
  rpc.call('transaction_status_api.find_transaction', { "transaction_id" => tx_id })
end

transaction = find_transaction('868e8d918f5fb370d5d4b47aaf9ba438ba06457f')

puts JSON.pretty_generate(transaction)
