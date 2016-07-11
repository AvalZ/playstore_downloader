class Apk
  attr_accessor :offer_type, :package_id, :version_code

  def initialize(package_id, version_code, offer_type)
    @package_id = package_id
    @version_code = version_code
    @offer_type = offer_type
  end

  def complete?
    @package_id.nil? && @version_code.nil? && @offer_type.nil?
  end

end
