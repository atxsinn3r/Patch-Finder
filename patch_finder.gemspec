# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'patch_finder/version'

Gem::Specification.new do |spec|
  spec.name          = 'patch_finder'
  spec.version       = '1.0.0'
  spec.authors       = ['wchen-r7']
  spec.email         = ['wei_chen@rapid7.com']
  spec.summary       = 'Patch Finder'
  spec.description   = 'Generic Patch Finder'
  spec.homepage      = 'http://github.com/wchen-r7/patch_finder'
  spec.license       = 'BSD-3-clause'


  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
