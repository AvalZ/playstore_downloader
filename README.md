# PlaystoreDownloader

Google Play Store lets you download an APK directly on your device, but sometimes you need to directly download the APK file on your PC (or other device). This gem lets you do just that, by using your credentials and tricking the Store into releasing the raw files to your device.
NOTE: it only works with free Apps.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'playstore_downloader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install playstore_downloader

## Usage

```ruby
PlaystoreDownloader::setup "abc@email.it", "password", "device_id"
PlaystoreDownloader::download "com.package.id"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/AvalZ/playstore\_downloader.

