require 'jwt'
require 'json'
require_relative './model_helpers'

# Helper module for app
module AppHelper
  include ModelHelper

  GOOGLE_API = 'https://www.googleapis.com/oauth2/'

  def callback_gmail(params)
    HTTParty.post(
      "#{GOOGLE_API}v3/token",
      body: { code: params['code'], client_id: ENV['CLIENT_ID'],
              client_secret: ENV['CLIENT_SECRET'],
              grant_type: 'authorization_code',
              redirect_uri: "#{request.base_url}/oauth2callback_gmail" },
      headers: { 'Accept' => 'application/json' }
    )
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
    teacher.password = enc_64(RbNaCl::Random.random_bytes(20))
    teacher.save ? login_teacher(email) : fail('Could not create new teacher')
  end

  def login_teacher(email)
    payload = { email: email }
    token = JWT.encode payload, ENV['MSG_KEY'], 'HS256'
    session[:auth_token] = token
    if session[:redirect]
      url = session[:redirect]
      session.delete(:redirect)
    else url = '/tokens'
    end
    redirect url
  end

  def find_user_by_token(token)
    return nil unless token
    decoded_token = JWT.decode token, ENV['MSG_KEY'], true
    payload = decoded_token.first
    Teacher.find_by_email(payload['email'])
  end
end
