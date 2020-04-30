require 'xgt/ruby'

def get_key_references(key)
  rpc = Xgt::Ruby::Rpc.new('http://localhost:8751')
  rpc.call('account_by_key_api.get_key_references', {'keys' => [key] })
end

references = get_key_references('XGT66jpLKLnpwbHoqwn7YMUmzBABoVP1GQeFYAy7rj5dfRYT6GUoR')

puts JSON.pretty_generate({'keys' => ['XGT66jpLKLnpwbHoqwn7YMUmzBABoVP1GQeFYAy7rj5dfRYT6GUoR'] })
puts "\n"
puts JSON.pretty_generate(references)
