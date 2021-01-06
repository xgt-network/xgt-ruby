require 'digest/sha2'
require 'xgt/ruby'
require 'base58'
hashed = Digest::SHA256.hexdigest('XGT5sDbeKuKKpw9hso8gs8zL6oN8ZCWrxCWMX5K7jR82z8cCLngb1')
p Base58.binary_to_base58(Xgt::Ruby::Auth.unhexlify(hashed))
