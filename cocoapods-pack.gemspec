# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-pack/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-pack'
  spec.version       = CocoapodsPack::VERSION
  spec.authors       = ['Square Inc.']
  spec.license       = 'Apache-2.0'
  spec.summary       = 'Converts a source podspec into its binary form.'
  spec.description   = <<~DESC
  A CocoaPods plugin that converts a given podspec into its binary version.
  For a given podspec, a zip file will be produced containing the binary representation of the original podspec sources.
  Each platform is packed as an `xcframework` within the zip file.
  Other attributes such as `resource_bundles` specified in the source podspec will also be packed.
  A binary podspec is also generated that can be published to a CocoaPods specs repo.
  DESC
  spec.homepage      = 'https://github.com/square/cocoapods-pack'
  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5.0'

  spec.add_dependency 'cocoapods', '>= 1.10', '< 2.0'
  spec.add_dependency 'rubyzip', '~> 2.0'

  spec.add_development_dependency 'activesupport', '~> 5.0'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
