# coding: utf-8

lib = File.expand_path("../lib", __FILE__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "iamport/version"

Gem::Specification.new do |spec|
  spec.name          = "iamport"
  spec.version       = Iamport::VERSION
  spec.authors       = ["Sell it"]
  spec.email         = ["webdeveloper@withsellit.com"]

  spec.summary       = "Ruby gem for Iamport"
  spec.description   = "Ruby gem for Iamport"
  spec.homepage      = "https://github.com/iamport/iamport-rest-client-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rubocop"

  spec.add_runtime_dependency "httparty"
end
