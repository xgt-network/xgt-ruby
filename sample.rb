require 'bundler/setup'
require 'time'
require 'xgt/ruby'

# -----
# Setup
# -----

# XXX: A transaction may require multiple wifs, if using multisig!
@wif = ENV['WIF'] || '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
@name = ENV['NAME'] || 'XGT0000000000000000000000000000000000000000'
@host = ENV['HOST'] || 'http://localhost:8751'
@address_prefix = 'XGT'

rpc = Xgt::Ruby::Rpc.new(@host)
generate_keys = ->() {
  master = Xgt::Ruby::Auth.random_wif
  ks = { 'master' => master }
  %w(recovery money social memo).each do |role|
    private_key = Xgt::Ruby::Auth.generate_wif(@name, master, 'recovery')
    public_key = Xgt::Ruby::Auth.wif_to_public_key(private_key, @address_prefix)
    ks["#{role}_private"] = private_key
    ks["#{role}_public"] = public_key
  end
  ks
}

#master = Xgt::Ruby::Auth.random_wif
#private_key = Xgt::Ruby::Auth.generate_wif(@name, master, 'recovery')
private_key = '5Kb8kLf9zgWQnogidDA76MzL6TsZZY36hWXMssSzNydYXYB9KF'
public_key = Xgt::Ruby::Auth.wif_to_public_key(private_key, @address_prefix)
p ['private_key', private_key]
p ['public_key', public_key]

response = rpc.call('wallet_by_key_api.generate_wallet_name', {
  'recovery_keys' => [public_key]
})
wallet_name = response['wallet_name']
p wallet_name

p Xgt::Ruby::Auth.generate_wallet_name(public_key)
