# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'highwatermark/version'

Gem::Specification.new do |spec|
  spec.name          = "highwatermark"
  spec.version       = Highwatermark::VERSION
  spec.authors       = ["Ling Zhang"]
  spec.email         = ["zhangling.ice@gmail.com"]

  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  # end

  spec.summary       = %q{High Watermark store and update}
  spec.description   = %q{store High Watermark in state file and update it periodically}
  spec.homepage      = "https://github.com/lingzhang-lyon/highwatermark"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "redis"
  spec.add_development_dependency "yaml"

end
