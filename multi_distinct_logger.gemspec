# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'multi_distinct_logger/version'

Gem::Specification.new do |spec|
  spec.name          = "multi_distinct_logger"
  spec.version       = MultiDistinctLogger::VERSION
  spec.authors       = ["Venkat-RK"]
  spec.email         = ["venkat.rk4@gmail.com"]

  spec.summary       = %q{Log to different log files and to distinct files based on logger level}
  spec.description   = %q{Log to different log files and to distinct files based on logger level}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
