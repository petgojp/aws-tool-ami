# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aws/tool/ami/version'

Gem::Specification.new do |spec|
  spec.name          = "aws-tool-ami"
  spec.version       = Aws::Tool::Ami::VERSION
  spec.authors       = ["marketing-info@petgo.co.jp"]
  spec.email         = ["marketing-info@petgo.co.jp"]

  spec.summary       = "CLI tool to backup AMI"
  spec.description   = "CLI tool to backup AMI"
  spec.homepage      = "https://github.com/petgojp/aws-tool-ami"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "thor", "0.19.1"
  spec.add_dependency "aws-sdk", "2.2.3"

end
