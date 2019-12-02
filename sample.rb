require 'bundler/setup'
require 'time'
require 'xgt/ruby'

wif = '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
# symbol = 'TESTS'
symbol = 'STEEM'
# address_prefix = 'TST'
# address_prefix = 'STM'
address_prefix = 'XGT'
chain_id = '0000000000000000000000000000000000000000000000000000000000000000'
name = 'foo' + SecureRandom.hex(6)
txn = {
  'extensions' => [],
  'operations' => [
    [
      'account_create',
      {
        'fee' => %(0.000 #{symbol}),
        'creator' => 'initminer',
        'new_account_name' => name,
        'owner' => {
          'weight_threshold' => 1,
          'account_auths' => [],
          'key_auths' => [
            [
              %(#{address_prefix}7xue5ESY1xHhDZj6dw2igXCwoHobA3cnxffacvp4XMzwfzLZu4),
              1
            ]
          ]
        },
        'active' => {
          'weight_threshold' => 1,
          'account_auths' => [],
          'key_auths' => [
            [
              %(#{address_prefix}6Yp3zeaYNU7XJF2MxoHhDcWT4vGgVkzTLEvhMY6g5tvmwzn3tN),
              1
            ]
          ]
        },
        'posting' => {
          'weight_threshold' => 1,
          'account_auths' => [],
          'key_auths' => [
            [
              %(#{address_prefix}5Q7ZdopjQWZMwiyZk11W5Yhvsfu1PG3f4qsQN58A7XfHP34Hig),
              1
            ]
          ]
        },
        'memo_key' => %(#{address_prefix}5u69JnHZ3oznnwn71J6VA4r5oVJX6Xu3dpbFVoHpJoZXnbDfaW),
        'json_metadata' => '',
        'extensions' => []
      }
    ]
  ]
}

rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
signed = Xgt::Ruby::Auth.sign_transaction(rpc, txn, [wif], chain_id)
puts %(Creating user named: #{name})
response = rpc.call('call', ['condenser_api', 'broadcast_transaction_synchronous', [signed]])
p response
puts %(Verifying the account was created:)
response = rpc.call('database_api.find_accounts', { 'accounts' => [name] })
p response
