require 'digest/sha2'
require 'xgt/ruby'
require 'base58'

# XXX: A transaction may require multiple wifs, if using multisig!
@wif = ENV['WIF'] || '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
@name = ENV['NAME'] || 'XGT0000000000000000000000000000000000000000'
@host = ENV['HOST'] || 'http://localhost:8751'
@address_prefix = 'XGT'

# hashed = Digest::SHA256.hexdigest('XGT5sDbeKuKKpw9hso8gs8zL6oN8ZCWrxCWMX5K7jR82z8cCLngb1')
hashed = Digest::SHA256.hexdigest('XGT5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ')
private_key = Base58.binary_to_base58(Xgt::Ruby::Auth.unhexlify(hashed))
public_key = Xgt::Ruby::Auth.wif_to_public_key(private_key, @address_prefix)
p public_key
