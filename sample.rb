require 'bundler/setup'
require 'time'
require 'xga/ruby'

wif = '5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n'
address_prefix = 'TST'
chain_id = '18dcf0a285365fc58b71f18b3d3fec954aa0c141c44e4e5cb4cf777b9eab274e'
now = (Time.now + 360).utc.iso8601.gsub(/Z$/, '')
name = 'foo' + SecureRandom.hex(6)
txn = {
  'expiration' => now,
  'extensions' => [],
  'operations' => [
    [
      'account_create',
      {
        'fee' => '0.000 TESTS',
        'creator' => 'initminer',
        'new_account_name' => name,
        'owner' => {
          'weight_threshold' => 1,
          'account_auths' => [],
          'key_auths' => [
            [
              'TST7xue5ESY1xHhDZj6dw2igXCwoHobA3cnxffacvp4XMzwfzLZu4',
              1
            ]
          ]
        },
        'active' => {
          'weight_threshold' => 1,
          'account_auths' => [],
          'key_auths' => [
            [
              'TST6Yp3zeaYNU7XJF2MxoHhDcWT4vGgVkzTLEvhMY6g5tvmwzn3tN',
              1
            ]
          ]
        },
        'posting' => {
          'weight_threshold' => 1,
          'account_auths' => [],
          'key_auths' => [
            [
              'TST5Q7ZdopjQWZMwiyZk11W5Yhvsfu1PG3f4qsQN58A7XfHP34Hig',
              1
            ]
          ]
        },
        'memo_key' => 'TST5u69JnHZ3oznnwn71J6VA4r5oVJX6Xu3dpbFVoHpJoZXnbDfaW',
        'json_metadata' => '',
        'extensions' => []
      }
    ]
  ],
  'ref_block_num' => 34960,
  'ref_block_prefix' => 883395518
}

rpc = Xga::Ruby::Rpc.new('http://localhost:8751')
signed = Xga::Ruby::Signature.sign_transaction(rpc, txn, [wif], address_prefix, chain_id)
puts %(Creating user named: #{name})
response = rpc.call('call', ['condenser_api', 'broadcast_transaction_synchronous', [signed]])
p response
puts %(Verifying the account was created:)
response = rpc.call('database_api.find_accounts', { 'accounts' => [name] })
p response
