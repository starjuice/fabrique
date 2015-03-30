# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fabrique/version'

Gem::Specification.new do |spec|
  spec.name          = "fabrique"
  spec.version       = Fabrique::VERSION
  spec.authors       = ["Sheldon Hearn"]
  spec.email         = ["sheldonh@starjuice.net"]
  spec.summary       = %q{Factory support library}
  spec.description   = %q{Factory support library for adapting existing modules for injection as dependencies}
  spec.homepage      = "https://github.com/starjuice/fabrique"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "cucumber", "~> 2.0"
end
