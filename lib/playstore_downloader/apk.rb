class Apk
  attr_accessor :offer_type, :package_id, :version_code

  def initialize(package_id, version_code, offer_type)
    @package_id = package_id
    @version_code = version_code
    @offer_type = offer_type
  end

end
