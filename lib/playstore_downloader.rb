require "playstore_downloader/version"
require "playstore_downloader/credentials"
require "net/http"

module PlaystoreDownloader

  module_function

  def req_google
    uri = URI 'http://www.google.it'
    response = Net::HTTP.get uri

    puts response
  end

  def setup
    @@credentials ||= Credentials.new nil, nil, nil
    yield(@@credentials) if block_given?
  end

  def auth
    uri = URI 'https://android.clients.google.com/auth'

    req = Net::HTTP::Post.new(uri)
      
    req.set_form_data(
      Email: @@credentials.email,
      Passwd: @@credentials.password,
      service: 'androidmarket',
      accountType: 'HOSTED_OR_GOOGLE',
      has_permission: '1',
      source: 'android',
      androidId: @@credentials.device_id,
      app: 'com.android.vending',
      device_country: 'it',
      operatorCountry: 'it',
      lang: 'it',
      sdk_version: '16'
    )

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true

    res = http.request req

    res.body[/(?<=Auth=).*/]

  end

end
