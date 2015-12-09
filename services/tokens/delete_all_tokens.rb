# Object that deletes all a user's tokens
class DeleteAllTokens
  def initialize(email)
    @tokens = Token.where(email: email)
  end

  def call
    @tokens.delete_all
  end
end
