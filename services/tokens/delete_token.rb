# Object that deletes a particular token
class DeleteToken
  def initialize(token)
    @token = token
  end

  def call
    @token.delete
  end
end
