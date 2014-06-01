# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |spec|
  spec.name          = "logjoin"
  spec.version       = Logjoin::VERSION
  spec.authors       = ["Rafael Biriba"]
  spec.email         = ["biribarj@gmail.com"]
  spec.description   = "Ruby script that join log files ordering the entries by date"
  spec.summary       = "Ruby script that join log files ordering the entries by date"
  spec.homepage      = "https://github.com/rafaelbiriba/logjoin"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
