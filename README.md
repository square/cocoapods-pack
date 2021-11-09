# cocoapods-pack

A CocoaPods plugin that converts a given podspec into its binary version.

For a given podspec, a zip file will be produced containing the binary representation of the original podspec sources. Each platform is packed as an `xcframework` within the zip file. Other attributes such as `resource_bundles` specified in the source podspec will also be packed. A binary podspec is also generated that can be published to a CocoaPods specs repo.

You may choose to use `cocoapods-pack` as a packaging tool and write your own Swift Package Manager `Package.swift` file for the generated package instead.

Finally, you may choose to write your own CocoaPods plugin that leverages `cocoapods-pack` to prebuild CocoaPods dependencies before integrating them into a project.


## Installation

```
gem install cocoapods-pack
```

## Usage
```
$ pod pack SOURCE ARTIFACT_REPO_URL

      Converts the provided `SOURCE` into a binary version with each platform packed
      as an `xcframework`. The process includes installing a CocoaPods sandbox,
      building it for device and simulator using the 'Release' configuration, zipping
      the output and generating a new podspec that uses the `ARTIFACT_REPO_URL`
      provided as the source. The generated podspec is also validated.

Options:

    --use-static-frameworks                           Produce a framework that wraps a
                                                      static library from the source
                                                      files. By default dynamic
                                                      frameworks are used.
    --generate-module-map                             If specified, instead of using
                                                      the default generated umbrella
                                                      module map one will be generated
                                                      based on the frameworks header
                                                      dirs.
    --allow-warnings                                  Lint validates even if warnings
                                                      are present.
    --repo-update                                     Force running `pod repo update`
                                                      before install.
    --out-dir                                         Optional directory to use to
                                                      output results into. Defaults to
                                                      current working directory.
    --skip-validation                                 Skips linting the generated
                                                      binary podspec.
    --skip-platforms                                  Comma-delimited platforms to
                                                      skip when creating a binary.
    --xcodebuild-opts                                 Options to be passed through to
                                                      xcodebuild.
    --use-json                                        Use JSON for the generated
                                                      binary podspec.
    --sources=https://github.com/artsy/Specs,master   The sources from which to pull
                                                      dependant pods (defaults to all
                                                      available repos). Multiple
                                                      sources must be comma-delimited.
    --allow-root                                      Allows CocoaPods to run as root
    --silent                                          Show nothing
    --verbose                                         Show more debugging information
    --no-ansi                                         Show output without ANSI codes
    --help                                            Show help banner of specified
                                                      command
```

## Examples

To run some of the examples in this repo make sure you run `bundle install` first.

```
bundle exec pod pack samples/MySample/MySample.podspec https://url/to/MySample.zip --out-dir=out
```

If you wish to skip a specific platform the source podspec provides:

```
bundle exec pod pack samples/MySample/MySample.podspec https://url/to/MySample.zip --skip-platforms=watchos --out-dir=out
```

Using static linking:

```
bundle exec pod pack samples/MySample/MySample.podspec https://url/to/MySample.zip --use-static-frameworks --out-dir=out
```

Additional `xcodebuild` options can be passed using `--xcodebuild-opts `, example:

```
bundle exec pod pack samples/MySample/MySample.podspec https://url/to/MySample.zip --use-static-frameworks --xcodebuild-opts=ENABLE_BITCODE=NO --out-dir=out
```

You may also specify a remote podspec without the need to clone its sources locally, for example:

```
bundle exec pod pack https://raw.githubusercontent.com/Alamofire/Alamofire/master/Alamofire.podspec https://url/to/Alamofire.zip --out-dir=out --allow-warnings
```

## Developing

Install Ruby >= 2.5.0 and set up with:

```
$ bundle
```

To run the unit tests use `rake`:

```
$ bundle exec rake spec
```

Or, for a more thorough output which include test names:

```
$ bundle exec rspec --format d
```
