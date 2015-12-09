# Object that saves a token
class SaveToken
  def initialize(current_teacher, token_set, params)
    @token = Token.new(email: current_teacher.email)
    @token_set = token_set
    @canvas_url = params['url']
    @canvas_token = params['token']
  end

  def call
    @token.nonce = @token_set
    @token.canvas_url = ([@canvas_url, @token_set])
    @token.canvas_token = ([@canvas_token, @token_set])
    unless @token.save
      return "Failed #{@token.canvas_token_display(@token_set)}"
    end
    "#{@token.canvas_token_display(@token_set)} saved"
  end
end
