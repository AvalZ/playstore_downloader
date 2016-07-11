class Credentials
  attr_accessor :email, :password, :device_id

  def initialize(email, password, device_id)
    @email = email
    @password = password
    @device_id = device_id
  end

end
