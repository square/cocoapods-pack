# frozen_string_literal: true

Pod::Spec.new do |s|
  s.name         = 'MySample'
  s.version      = '0.0.1'
  s.summary      = 'A small summary on MySample library.'

  s.description  = <<-DESC
                   A longer description of MySample in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
  DESC

  s.homepage = 'http://squareup.com/'
  s.cocoapods_version = '>= 1.0'

  s.license = { type: 'MIT', file: 'MIT' }

  s.author = { 'Square Inc.' => 'someemail@gmail.com' }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '3.0'

  s.swift_version = '5.0'

  s.source = { git: 'local only', tag: s.version.to_s }

  s.source_files = 'MySample', 'MySample/**/*.{h,m,swift}'
  s.public_header_files = 'MySample/**/*.h'
  s.private_header_files = 'MySample/Internal/**/*.h'
  s.exclude_files = 'MySample/Exclude'

  s.ios.frameworks = 'iAd', 'SystemConfiguration', 'CoreTelephony', 'MobileCoreServices'

  s.user_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) SOMETHING=1' }
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) SOMETHING=1' }

  s.resource = '**/*.png'

  s.preserve_paths = 'python/a.py', 'python/subpython/b.py'
end
