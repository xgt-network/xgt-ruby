require 'xgt/ruby'

def delegate_some_vesting_shares
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  wif = '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
  config = rpc.call('database_api.get_config', {})
  address_prefix = config['XGT_ADDRESS_PREFIX']
  chain_id = config["XGT_CHAIN_ID"]

  vesting_shares = "#{'%.6f' % 10}"
  
  txn = {
    "extensions": [],
    "operations": [
      [
        "delegate_vesting_shares",
          {
            "delegator": "XGT0000000000000",
            "delegatee": "XGT272up7iTGKArE",
            "vesting_shares": "#{vesting_shares} VESTS"
          }
      ]
    ]
  }

  signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [wif], chain_id)
  puts JSON.pretty_generate(signed)
  response = rpc.call('network_broadcast_api.broadcast_transaction_synchronous', [signed])
  puts JSON.pretty_generate(response)
end

delegate_some_vesting_shares
