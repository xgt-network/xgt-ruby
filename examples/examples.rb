require 'xgt/ruby'

def create_wallet()
  
  current_name = "XGT0000000000000"
  wif = '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
  address_prefix = 'XGT'
  # Connect to local node
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  response = rpc.call('database_api.get_config', nil)
  chain_id = response["XGT_CHAIN_ID"]

  witness_schedule = rpc.call('database_api.get_witness_schedule', {}) || {}
  chain_properties = witness_schedule['median_props']

  fee = chain_properties["account_creation_fee"] || {}
  amount = fee['amount'].to_f * 0.001
  creation_fee = "#{'%0.3f' % amount} XGT"
  # Generate keys
  creator_wif = Xgt::Ruby::Auth.generate_wif(current_name, wif, 'money')
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
        'json_metadata' => '',
        'extensions' => []
      }
    ]]
  }

 
  signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [wif], chain_id)
  response = rpc.call('network_broadcast_api.broadcast_transaction_synchronous', [signed])
  p response

  puts %(Verifying the account was created:)
  response = rpc.call('database_api.find_accounts', { 'accounts' => [current_name] })
  p response         
end
  
create_wallet()


# 1. Create a wallet - same as creating steem account
# 2. Do a transfer - load up account with xgt - initminer has all the xgt at the beginning. Transfer from initminer to new account. As little code as possible to create wallet and transfer xgt into wallet. 
#   a. Make a connection Formulate chunk of json using json rpc, send down connection# want to see the json that gets sent over the wire and the json that comes back
# paste responses and requests into the docs
# wallet will give connection to server
# all i really want is the json to go into the docs
# look for connection in xgt-ruby, have it shit out json

# mission - json to put in docs for creating wallet/account - sent and received ALL I WANT IS JSON
# mission2: same but for transaction/transfer from initminer to wallet
# bonus: get current balance from wallet
