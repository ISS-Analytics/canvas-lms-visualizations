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

  def list_tokens
    tokens = Token.where(email: @current_teacher.email)
    return tokens unless tokens
    tokens.map { |token| [token.canvas_token_display, token.canvas_url] }
  end

  def save_token(canvas_token, canvas_url)
    token = Token.new(email: @current_teacher.email, canvas_url: canvas_url)
    token.canvas_token = canvas_token
    return "Failed to save #{token.canvas_token_display}" unless token.save
    "#{token.canvas_token_display} saved"
  end

  def permitted_tokens(canvas_token_display)
    tokens = Token.where(email: @current_teacher.email)
    tokens.select do |token|
      token.canvas_token_display.include? canvas_token_display
    end[0]
  end

  def cross_tokens(canvas_token_display)
    permitted = permitted_tokens(canvas_token_display)
    return permitted if permitted
    flash[:error] = 'You do not own this token!' # Overly risky handling
    redirect '/tokens'
  end

  def api_party(url, canvas_token)
    headers = { 'authorization' => ('Bearer ' + canvas_token) }
    (HTTParty.get url, headers: headers).to_json
  end

  def courses(canvas_api, canvas_token)
    url = canvas_api + 'courses'
    api_party(url, canvas_token)
  end

  def course_analytics(canvas_api, canvas_token, course_id, data)
    url = canvas_api + 'courses/' + course_id + "/analytics/#{data}"
    api_party(url, canvas_token)
  end

  def course_info(canvas_api, canvas_token, course_id, data)
    url = canvas_api + 'courses/' + course_id + "/#{data}"
    api_party(url, canvas_token)
  end

  def all_discussion(canvas_api, canvas_token, course_id, data)
    discussions = course_info(canvas_api, canvas_token, course_id, data)
    discussions = JSON.parse(discussions)
    discussions.map do |discussion|
      Concurrent::Future.new do
        course_info(canvas_api, canvas_token, course_id,
                    "/#{data}/#{discussion['id']}/view")
      end; end.map(&:execute).map(&:value).to_json
  end
end
