# Object to find user linked to email from session variable
class GetTeacherInSessionVar
  def initialize(token)
    @token = token
  end

  def call
    return nil unless @token
    decoded_token = JWT.decode @token, ENV['MSG_KEY'], true
    payload = decoded_token.first
    Teacher.find_by_email(payload['email'])
  end
end
