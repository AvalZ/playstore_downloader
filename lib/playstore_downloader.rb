require 'openssl'
require "net/http"

require 'playstore_parser'

require "playstore_downloader/version"
require "playstore_downloader/credentials"
require "playstore_downloader/apk"


module PlaystoreDownloader

  @@auth_token ||= nil
  AUTH_URI = 'https://android.clients.google.com/auth'
  BASE_URI = 'https://android.clients.google.com/fdfe'

  module_function

  def setup(email, password, device_id)
    @@credentials = Credentials.new email, password, device_id
  end

  def auth
    uri = URI(AUTH_URI)

    req = Net::HTTP::Post.new(uri)
      
    req.set_form_data(
      Email: @@credentials.email,
      Passwd: @@credentials.password,
      service: 'androidmarket',
      accountType: 'HOSTED_OR_GOOGLE',
      has_permission: 1,
      source: 'android',
      androidId: @@credentials.device_id,
      app: 'com.android.vending',
      device_country: 'it',
      operatorCountry: 'it',
      lang: 'it',
      sdk_version: 16
    )

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true

    res = http.request req

    @@auth_token = res.body[/(?<=Auth=).*/]
  end

  def details(apk)
    auth if @@auth_token.nil?

    uri = URI(BASE_URI + "/details?doc=#{apk.package_id}")

    headers = {
      'Accept' => 'application/xml',
      'Accept-Language' => 'en_US',
      'Authorization' => "GoogleLogin auth=#{@@auth_token}",
      'X-DFE-Device-Id' => @@credentials.device_id,
      'X-DFE-Client-Id' => 'am-android-google',
      'User-Agent' => 'Android-Finsky/3.7.13 (api=3,versionCode=8013013,sdk=16,device=crespo,hardware=herring,product=soju)',
      'X-DFE-SmallestScreenWidthDp' => '320',
      'X-DFE-Filter-Level' => '3',
      'Accept-Encoding' => '',
      'Host' => 'android.clients.google.com'
    }

    req = Net::HTTP::Get.new(uri.to_s)
    
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|


      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true

      headers.each do |key, value|
        req[key] = value
      end

      http.request req

    end


    rw = PlaystoreParser.parse(res.body)

    doc = rw.payload.detailsResponse.docV2
      
    apk.version_code = doc.details.appDetails.versionCode
    apk.offer_type = doc.offer[0].offerType

    return apk
  
  end


  def purchase(apk)
    auth if @@auth_token.nil?
    
    details(apk) unless apk.complete?

    uri = URI(BASE_URI + '/purchase')

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true

    headers = {
      'Accept' => 'application/xml',
      'Accept-Language' => 'en_US',
      'Authorization' => "GoogleLogin auth=#{@@auth_token}",
      'X-DFE-Enabled-Experiments' => 'cl:billing.select_add_instrument_by_default',
      'X-DFE-Unsupported-Experiments' => 'nocache:billing.use_charging_poller,market_emails,buyer_currency,prod_baseline,checkin.set_asset_paid_app_field,shekel_test,content_ratings,buyer_currency_in_app,nocache:encrypted_apk,recent_changes',
      'X-DFE-Device-Id' => @@credentials.device_id,
      'X-DFE-Client-Id' => 'am-android-google',
      'User-Agent' => 'Android-Finsky/3.7.13 (api=3,versionCode=8013013,sdk=16,device=crespo,hardware=herring,product=soju)',
      'X-DFE-SmallestScreenWidthDp' => '320',
      'X-DFE-Filter-Level' => '3',
      'Accept-Encoding' => '',
      'Host' => 'android.clients.google.com',
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
    }

    req = Net::HTTP::Post.new(BASE_URI + '/purchase')

    req.set_form_data(
      ot: apk.offer_type,
      doc: apk.package_id,
      vc: apk.version_code
    )

    headers.each do |key, value|
      req.add_field key, value
    end

    res = http.request req

    rw = PlaystoreParser.parse(res.body)

    delivery_data = rw.payload.buyResponse.purchaseStatusResponse.appDeliveryData

    auth_cookie = delivery_data.downloadAuthCookie[0]

    download_data = {
      dl_url: delivery_data.downloadUrl,
      dl_auth_cookie: auth_cookie.name + "=" + auth_cookie.value
    }


  end

  def download_apk(dl_data)
    uri = URI(dl_data[:dl_url])
    auth_cookie = dl_data[:dl_auth_cookie]
    Net::HTTP.start(uri.hostname, use_ssl: uri.scheme == 'https') do |http|
      req = Net::HTTP::Get.new uri
      req['User-Agent'] = 'AndroidDownloadManager Paros/3.2.13'
      req['Cookie'] = auth_cookie

      res = http.request req

      case res
      when Net::HTTPSuccess
        return res
      when Net::HTTPRedirection
        return download_apk({dl_url: res['Location'], dl_auth_cookie: auth_cookie})
      else
        res.error!
      end

    end
  end

  def download(package_id)
    apk = Apk.new(package_id, nil, nil)
    dl_data = purchase apk
    res = download_apk dl_data

    return res.body
  end

end
