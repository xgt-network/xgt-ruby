require 'xgt/ruby'

# Requires local node: clone into xgt repo, rake run

module Dummy_code

def Dummy_code.account_create()

  current_name = ENV["NAME"] || "XGT0000000000000"
  wif = ENV["WIF"] || '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  config = rpc.call('database_api.get_config', {})
  address_prefix = config['XGT_ADDRESS_PREFIX']
  chain_id = config["XGT_CHAIN_ID"]

  witness_schedule = rpc.call('database_api.get_witness_schedule', {}) || {}
  chain_properties = witness_schedule['median_props']

  fee = chain_properties["account_creation_fee"] || {}
  amount = fee['amount'].to_f * 0.001
  creation_fee = "#{'%0.3f' % amount} XGT"

# Generate keys
  master = Xgt::Ruby::Auth.random_wif
  recovery_private = Xgt::Ruby::Auth.generate_wif(current_name, master, 'recovery')
  recovery_public = Xgt::Ruby::Auth.wif_to_public_key(recovery_private, address_prefix)
  money_private = Xgt::Ruby::Auth.generate_wif(current_name, master, 'money')
  money_public = Xgt::Ruby::Auth.wif_to_public_key(money_private, address_prefix)
  social_private = Xgt::Ruby::Auth.generate_wif(current_name, master, 'social')
  social_public = Xgt::Ruby::Auth.wif_to_public_key(social_private, address_prefix)
  memo_private = Xgt::Ruby::Auth.generate_wif(current_name, master, 'memo')
  memo_public = Xgt::Ruby::Auth.wif_to_public_key(memo_private, address_prefix)

  txn = {
    'extensions' => [],
    'operations' => [[
      'account_create',
    {
      'fee' => creation_fee,
      'creator' => current_name,
      'recovery' => {
        'weight_threshold' => 1,
        'account_auths' => [],
        'key_auths' => [[recovery_public, 1]]
      },
      'money' => {
        'weight_threshold' => 1,
        'account_auths' => [],
        'key_auths' => [[money_public, 1]]
      },
      'social' => {
        'weight_threshold' => 1,
        'account_auths' => [],
        'key_auths' => [[social_public, 1]]
      },
      'memo_key' => memo_public,
      'json_metadata' => "",
      'extensions' => []
    }
    ]]
  }

  signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [wif], chain_id)
  signed
  end
end
