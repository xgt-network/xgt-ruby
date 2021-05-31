require 'digest/sha2'
require 'xgt/ruby'
require 'base58'
require 'bigdecimal'

@wif = ENV['WIF'] || '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
@name = ENV['NAME'] || 'XGT0000000000000000000000000000000000000000'
@host = ENV['HOST'] || 'http://localhost:8751'
@address_prefix = ENV['ADDRESS_PREFIX'] || 'XGT'
@precision = ENV['PRECISION'] || 8
@bitcoin_key = ENV['BITCOIN_KEY'] || '5Kb8kLf9zgWQnogidDA76MzPL6TsZZY36hWXMssSzNydYXYB9KF'

def rpc
  Xgt::Ruby::Rpc.new(@host || 'http://localhost:8751')
end

def config
  rpc.call('database_api.get_config', {})
end

def chain_id
  config['XGT_CHAIN_ID']
end

def transfer_operation(wallet_name, amount)
  {
    'type' => 'transfer_operation',
    'value' => {
      'amount' => {
        'amount' => ( amount * (10 ** @precision) ).to_i.to_s,
        'precision' => @precision,
        'nai' => '@@000000021'
      },
      'from' => @name,
      'to' => wallet_name,
      'json_metadata' => '',
    }
  }
end

def wallet_update_operation(wallet_name, keys)
  {
    'type' => 'wallet_update_operation',
    'value' => {
      'wallet' => wallet_name,
      'recovery' => {
        'weight_threshold' => 1,
        'account_auths' => [],
        'key_auths' => [[keys['recovery_public'], 1]]
      },
      'money' => {
        'weight_threshold' => 1,
        'account_auths' => [],
        'key_auths' => [[keys['money_public'], 1]]
      },
      'social' => {
        'weight_threshold' => 1,
        'account_auths' => [],
        'key_auths' => [[keys['social_public'], 1]]
      },
      'memo_key' => keys['memo_public'],
      'json_metadata' => '',
    }
  }
end

# Generate a set of keys from a parent wallet name and master key
def generate_keys(from_wallet_name, master_key)
  ks = { 'master' => master_key }
  %w(recovery money social memo).each do |role|
    private_key = Xgt::Ruby::Auth.generate_wif(from_wallet_name, master_key, 'recovery')
    public_key = Xgt::Ruby::Auth.wif_to_public_key(private_key, @address_prefix)
    ks["#{role}_private"] = private_key
    ks["#{role}_public"] = public_key
  end
  ks['wallet_name'] = Xgt::Ruby::Auth.generate_wallet_name(ks['recovery_public'])
  ks
end

# Query the node for a wallet name given a public key
def fetch_wallet_name(public_key)
  result = rpc.call('wallet_by_key_api.get_key_references', { 'keys' => [keys['recovery_public']] })
  result&.fetch('wallets', [])&.first&.first
end

if __FILE__ == $0
  # Generate keys
  keys = generate_keys(@name, @bitcoin_key)
  recovery_private = keys['recovery_private']
  recovery_public = keys['recovery_public']

  # Create lazy wallet
  txn = { 'operations' => [ transfer_operation(wallet_name, BigDecimal('0.00000001')) ] }
  id = rpc.broadcast_transaction(txn, [@wif], chain_id)
  (puts 'Waiting...' or sleep 1) until rpc.transaction_ready?(id)
  puts 'Done!'

  # Redeem lazy wallet
  txn = { 'operations' => [ wallet_update_operation(wallet_name, keys) ] }
  id = rpc.broadcast_transaction(txn, [recovery_private], chain_id)
  (puts 'Waiting...' or sleep 1) until fetch_wallet_name(recovery_public)
  puts 'Done!'
  p keys
end
