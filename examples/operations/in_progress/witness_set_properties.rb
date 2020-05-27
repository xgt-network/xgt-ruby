require 'pathname'
require 'erb'
require 'pp'
require 'benchmark'
require 'yaml'
require 'bigdecimal'
require 'uri'
require 'openssl'
$LOAD_PATH.unshift(%(#{File.dirname(__FILE__)}/../xgt-ruby/lib))
require'xgt/ruby'

def msg(message)
  puts "\e[36m#{message}\e[0m"
end

def create_witness
  rpc = Xgt::Ruby::Rpc.new("http://localhost:8751")
  recovery_wif = '5JkEZbn8i8BDRpzTAt38Cj9jhAytkcsPuxbFB6R8kd2L7sGWcbE'
  config = rpc.call('database_api.get_config', {})
  witness_schedule = rpc.call('database_api.get_witness_schedule', {}) || {}
  chain_properties = witness_schedule['median_props']
  address_prefix = config['XGT_ADDRESS_PREFIX']
  chain_id = config['XGT_CHAIN_ID']
  signing_private = Xgt::Ruby::Auth.random_wif
  signing_public = Xgt::Ruby::Auth.wif_to_public_key(signing_private, address_prefix)
  amount = (chain_properties['account_creation_fee'] || {})['amount'].to_f * 0.001
  currency_symbol = config['XGT_SYMBOL_STR']
  fee = "#{'%0.3f' % amount} #{currency_symbol}"
  components = fee.split(' ')
  decimal = BigDecimal(components.first) * 1
  final_fee = decimal.truncate.to_s + '.' + sprintf('%03d', (decimal.frac * 1000).truncate) + ' ' + components.last

  txn = {
    "operations": [[
      "witness_set_properties",
      {
        "owner": "XGT25svCHdyiRN1C",
        "maximum_block_size": 65536,
        "props": [
          "new_signing_key": "5JANXuPvF1DuhEpf2AKCDhMgaY7ZhYj6qM6HtKUfvnLkuZ6JwGZ",
        ]
      }
    ]]
  }

  signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [recovery_wif], chain_id)
  puts JSON.pretty_generate(signed)
  puts "\n\n"

  msg %(Registering witness "XGT272up7iTGKArE" with recovery private WIF "#{recovery_wif}"...)
  msg %(Signing keypair is #{signing_private} (private) and #{signing_public} (public)...)
  response = rpc.call('network_broadcast_api.broadcast_transaction_synchronous', [signed])
  puts "\n\n"
  puts JSON.pretty_generate(response)

  {
    signing_private: signing_private,
    signing_public: signing_public
  }
end

create_witness


