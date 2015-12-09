# Object that returns all a user's tokens
class ListTokens
  def initialize(current_teacher, token_set)
    @tokens = Token.where(email: current_teacher.email)
    @token_set = token_set
  end

  def call
    return @tokens unless @tokens
    @tokens.map do |token|
      [token.canvas_token_display(@token_set), token.canvas_url(@token_set),
       token.access_key]
    end
  end
end
