require 'xgt/ruby'

def account_update  
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  wif = '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
  config = rpc.call('database_api.get_config', {})
  address_prefix = config['XGT_ADDRESS_PREFIX']
  chain_id = config['XGT_CHAIN_ID']

   txn = {
    "extensions": [],
    "operations": [
      [
        "account_update2",
        {
          "account": "XGT0000000000000",
          "posting": {
            "weight_threshold": 1,
            "account_auths": [],
            "key_auths": [
              [
                "XGT6FATHLohxTN8RWWkU9ZZwVywXo6MEDjHHui1jEBYkG2tTdvMYo",
                1
              ],
              [
                "XGT76EQNV2RTA6yF9TnBvGSV71mW7eW36MM7XQp24JxdoArTfKA76",
                1
              ]
            ]
          },
          "memo_key": "XGT6FATHLohxTN8RWWkU9ZZwVywXo6MEDjHHui1jEBYkG2tTdvMYo",
          "json_metadata": ""
        }
      ]
    ]
  }

  signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [wif], chain_id)
  puts JSON.pretty_generate(signed)
  response = rpc.call('network_broadcast_api.broadcast_transaction_synchronous', [signed])
  puts JSON.pretty_generate(response)
end

account_update
