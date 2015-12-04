require_relative './model_helpers'

# Helper module for app, handling login
module AppLoginHelper
  include ModelHelper

  def find_teacher(email)
    Teacher.find_by_email(email)
  end

  def register_teacher(email)
    teacher = Teacher.new(email: email)
    teacher.save ? login_teacher(email) : fail('Could not create new teacher')
  end

  def delete_tokens(email)
    tokens = Token.where(email: email)
    tokens.delete_all
  end

  def login_teacher(email)
    payload = { email: email }
    token = JWT.encode payload, ENV['MSG_KEY'], 'HS256'
    session[:auth_token] = token
    redirect '/welcome'
  end

  def create_password(password)
    delete_tokens(@current_teacher.email)
    teacher = find_teacher(@current_teacher.email)
    teacher.password = password
    if teacher.save
      payload = session_password(password, teacher.token_salt)
      session[:unleash_token] = payload
      redirect '/tokens'
    else
      fail('This is a weird one.')
    end
  end

  def retrieve(password)
    return no_password if @current_teacher.hashed_password.nil?
    teacher = Teacher.authenticate!(@current_teacher.email, password)
    if teacher
      session[:unleash_token] = session_password(password, teacher.token_salt)
      redirect '/tokens'
    else
      flash[:error] = 'Wrong Password'
      redirect '/welcome'
    end
  end

  def no_password
    flash[:error] = 'You\'re yet to save a password.'
    redirect '/welcome'
  end

  def session_password(password, tsalt)
    payload = enc_64(Teacher.token_key(password, dec_64(tsalt)))
    payload = { key: payload }
    JWT.encode payload, ENV['MSG_KEY'], 'HS256'
  end

  def find_user_by_token(token)
    return nil unless token
    decoded_token = JWT.decode token, ENV['MSG_KEY'], true
    payload = decoded_token.first
    Teacher.find_by_email(payload['email'])
  end

  def avail_tokens_for_user(token)
    return nil unless token
    decoded_token = JWT.decode token, ENV['MSG_KEY'], true
    payload = decoded_token.first
    payload['key']
  end
end
