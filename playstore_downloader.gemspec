# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'playstore_downloader/version'

Gem::Specification.new do |spec|
  spec.name          = "playstore_downloader"
  spec.version       = PlaystoreDownloader::VERSION
  spec.authors       = ["avalz"]
  spec.email         = ["avalenza89@gmail.com"]

  spec.summary       = %q{Download Free APKs directly from the Google Play Store}
  spec.description   = %q{Google Play Store lets you download an APK directly on your device, but sometimes you need to directly download the APK file on your PC (or other device). This gem lets you do just that, by using your credentials and tricking the Store into releasing the raw files to your device.}
  spec.homepage      = "https://github.com/AvalZ/playstore_downloader"
  spec.license       = "MIT"


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
