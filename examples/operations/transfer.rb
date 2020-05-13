require 'xgt/ruby'

def transfer
  # Connect to chain
  wif = '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  config = rpc.call('database_api.get_config', {})
  chain_id = config['XGT_CHAIN_ID']
  witness_schedule = rpc.call('database_api.get_witness_schedule', {}) || {}
  chain_properties = witness_schedule['median_props']
  fee = chain_properties['account_creation_fee'] || {}
  amount = fee['amount'].to_f * 0.001
  creation_fee = "#{'%0.3f' % amount} XGT"
  currency_symbol = creation_fee.split(/\s+/).last
  string_amount = '%.3f' % (1000 * 0.001)

  txn = {
    'extensions': [],
    'operations': [
      [
        'transfer',
        {
          'from': 'XGT0000000000000',
          'to': 'XGT272up7iTGKArE',
          'amount': %(#{string_amount} #{currency_symbol}),
          'memo': '',
          'json_metadata': '',
        }
      ]
    ]
  }

  puts "\e[36mSent:\n\e[0m"
  puts JSON.pretty_generate(txn)
  signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [wif], chain_id)
  puts "\e[36m\nSigned:\n\e[0m"
  puts JSON.pretty_generate(signed)
  response = rpc.call('call', ['network_broadcast_api', 'broadcast_transaction_synchronous', [signed]])
  puts "\e[36m\nResponse:\n\e[0m"
  puts JSON.pretty_generate(response)
  response
end

transfer
