# Object to save user password as session variable
class SavePasswordToSessionVar
  include ModelHelper

  def initialize(password, tsalt)
    @password = password
    @tsalt = tsalt
  end

  def call
    payload = base_64_encode(
      Teacher.token_key(@password, base_64_decode(@tsalt))
    )
    payload = { specially_hashed_password: payload }
    JWT.encode payload, ENV['MSG_KEY'], 'HS256'
  end
end
