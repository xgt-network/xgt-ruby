require 'bundler/setup'
require 'time'
require 'xgt/ruby'

# -----
# Setup
# -----

# XXX: A transaction may require multiple wifs, if using multisig!
@wif = ENV['WIF'] || '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
@name = ENV['NAME'] || 'initminer'
@host = ENV['HOST'] || 'http://localhost:8751'

rpc = Xgt::Ruby::Rpc.new(@host)
chain_properties = rpc.call('condenser_api.get_chain_properties', [])
config = rpc.call('condenser_api.get_config', [])

@address_prefix = config['STEEM_ADDRESS_PREFIX']
@chain_id = config['STEEM_CHAIN_ID']
@fee = chain_properties['account_creation_fee']

creator_wif = Xgt::Ruby::Auth.generate_wif(@name, @wif, 'active')
master = Xgt::Ruby::Auth.random_wif
owner_private = Xgt::Ruby::Auth.generate_wif(@name, master, 'owner')
owner_public = Xgt::Ruby::Auth.wif_to_public_key(owner_private, @address_prefix)
active_private = Xgt::Ruby::Auth.generate_wif(@name, master, 'active')
active_public = Xgt::Ruby::Auth.wif_to_public_key(active_private, @address_prefix)
posting_private = Xgt::Ruby::Auth.generate_wif(@name, master, 'posting')
posting_public = Xgt::Ruby::Auth.wif_to_public_key(posting_private, @address_prefix)
memo_private = Xgt::Ruby::Auth.generate_wif(@name, master, 'memo')
memo_public = Xgt::Ruby::Auth.wif_to_public_key(memo_private, @address_prefix)

# --------------
# Create account
# --------------

# Generate the transaction
txn = {
  'extensions' => [],
  'operations' => [
    [
      'account_create',
      {
        'fee' => @fee,
        'creator' => @name,
        'owner' => {
          'weight_threshold' => 1,
          'account_auths' => [],
          'key_auths' => [[owner_public]]
        },
        'active' => {
          'weight_threshold' => 1,
          'account_auths' => [],
          'key_auths' => [[active_public]]
        },
        'posting' => {
          'weight_threshold' => 1,
          'account_auths' => [],
          'key_auths' => [[posting_public]]
        },
        'memo_key' => memo_public,
        'json_metadata' => '',
        'extensions' => []
      }
    ]
  ]
}

# Sign the transaction
signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [@wif], @chain_id)

# Create the user
puts %(Creating user...)
response = rpc.call('call', ['condenser_api', 'broadcast_transaction_synchronous', [signed]])
p response
puts

# Use the block ID to query for the account name for the new account
puts %(Fetching account name...)
account_names = rpc.call('condenser_api.get_account_names_by_block_num', [response['block_num']])
p account_names
account_name = account_names.first
puts

# Verify the account
puts %(Verifying the account named "#{account_name}" was created...)
response = rpc.call('database_api.find_accounts', { 'accounts' => [account_name] })
p response
