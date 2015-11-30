# BIG DO-OVER
require 'jwt'
require 'json'
require_relative './model_helpers'

# Helper module for app, handling login
module AppLoginHelper
  include ModelHelper

  GOOGLE_API = 'https://www.googleapis.com/oauth2/'

  def callback_gmail(params)
    HTTParty.post(
      "#{GOOGLE_API}v3/token",
      body: { code: params['code'], client_id: ENV['CLIENT_ID'],
              client_secret: ENV['CLIENT_SECRET'],
              grant_type: 'authorization_code',
              redirect_uri: "#{request.base_url}/oauth2callback_gmail" },
      headers: { 'Accept' => 'application/json' })
  end

  def teacher_email(access_token)
    url = "#{GOOGLE_API}v2/userinfo"
    headers = { 'authorization' => "Bearer #{access_token}" }
    results_json = (HTTParty.get url, headers: headers).to_json
    JSON.parse(results_json)['email']
  end

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
