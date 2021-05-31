lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xgt/ruby/version'

Gem::Specification.new do |spec|
  spec.name          = 'xgt-ruby'
  spec.version       = Xgt::Ruby::VERSION
  spec.authors       = ['Roger Jungemann']
  spec.email         = ['roger@gather.com']

  spec.summary       = %q(XGT client library)
  spec.homepage      = %q(https://github.com/gather-com/xgt-ruby)
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_dependency 'faraday', '~> 0.15.4'
  spec.add_dependency 'faraday_middleware', '~> 0.13.1'
  spec.add_dependency 'bitcoin-ruby', '~> 0.0.19'
  spec.add_dependency 'base58', '~> 0.2.3'
end
