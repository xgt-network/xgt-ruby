require 'xgt/ruby'

def create_claimed_account  
rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  wif = '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
  config = rpc.call('database_api.get_config', {})
  address_prefix = config['XGT_ADDRESS_PREFIX']
  chain_id = config["XGT_CHAIN_ID"]

  txn = {
    "extensions": [],
    "operations": [
      [
        "create_claimed_account",
          {
            "creator": "XGT0000000000000",
            "new_account_name": "XGT1234567890123",
            "recovery": {
              "weight_threshold": 1,
              "account_auths": [],
              "key_auths": [
                [
                  "XGT5b4i9gBqvh4sbgrooXPu2dbGLewNPZkXeuNeBjyiswnu2szgXx",
                  1
                ]
              ]
            },
            "money": {
              "weight_threshold": 1,
              "account_auths": [],
              "key_auths": [
                [
                  "XGT7ko5nzqaYfjbD4tKWGmiy3xtT9eQFZ3Pcmq5JmygTRptWSiVQy",
                  1
                ]
              ]
            },
            "social": {
              "weight_threshold": 1,
              "account_auths": [],
              "key_auths": [
                [
                  "XGT5xAKxnMT2y9VoVJdF63K8xRQAohsiQy9bA33aHeyMB5vgkzaay",
                  1
                ]
              ]
            },
            "memo_key": "XGT8ZSyzjPm48GmUuMSRufkVYkwYbZzbxeMysAVp7KFQwbTf98TcG",
            "json_metadata": "{}"
          }
      ]
    ]
  }
  
  signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [wif], chain_id)
  puts JSON.pretty_generate(signed)
  puts "\n\n"
  response = rpc.call('network_broadcast_api.broadcast_transaction_synchronous', [signed])
  puts JSON.pretty_generate(response)
end

create_claimed_account
