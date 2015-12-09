# Object to get password stored in session variable
class GetPasswordInSessionVar
  def initialize(token)
    @token = token
  end

  def call
    return nil unless @token
    decoded_token = JWT.decode @token, ENV['MSG_KEY'], true
    payload = decoded_token.first
    payload['specially_hashed_password']
  end
end
