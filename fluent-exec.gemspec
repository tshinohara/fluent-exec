# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fluent-exec/version'

Gem::Specification.new do |gem|
  gem.name          = "fluent-exec"
  gem.version       = Fluent::Exec::VERSION
  gem.authors       = ["Takenari Shinohara"]
  gem.email         = ["takenari.shinohara@gmail.com"]
  gem.description   = "Log command's exit status, output and runtime to fluentd."
  gem.summary       = "Log command's exit status, output and runtime to fluentd."
  gem.homepage      = "https://github.com/tshinohara/fluent-exec"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'fluent-logger', '~>0.4.3'
end
