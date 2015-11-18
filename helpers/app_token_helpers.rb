# Helper module to dealing with tokens
module AppTokenHelper
  def list_tokens
    tokens = Token.where(email: @current_teacher.email)
    return tokens unless tokens
    tokens.map do |token|
      [token.canvas_token_display(@token_set), token.canvas_url(@token_set)]
    end
  end

  def delete_token(token)
    if token.delete
      flash[:notice] = "Successfully deleted #{params['canvas_token_display']}"
    else
      flash[:error] = 'This is a strange one'
    end
  end

  def save_token(canvas_token, canvas_url)
    token = Token.new(email: @current_teacher.email)
    token.nonce = @token_set
    token.canvas_url = ([canvas_url, @token_set])
    token.canvas_token = ([canvas_token, @token_set])
    return "Failed #{token.canvas_token_display(@token_set)}" unless token.save
    "#{token.canvas_token_display(@token_set)} saved"
  end

  def permitted_tokens(canvas_token_display)
    tokens = Token.where(email: @current_teacher.email)
    tokens.select do |token|
      token.canvas_token_display(@token_set).include? canvas_token_display
    end[0]
  end

  def cross_tokens(canvas_token_display)
    permitted = permitted_tokens(canvas_token_display)
    return permitted if permitted
    flash[:error] = 'You do not own this token!'
    redirect '/tokens'
  end
end
