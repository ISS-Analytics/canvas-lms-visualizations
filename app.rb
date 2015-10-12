require 'sinatra'
require 'config_env'
require 'rack/ssl-enforcer'
require 'httparty'
require 'slim'
require 'slim/include'
require_relative './model/teacher'
require_relative './model/token'

configure :development, :test do
  ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
end

# Custom ~'wrapper' for the Canvas LMS API
class CanvasLmsAPI < Sinatra::Base
  configure :production do
    use Rack::SslEnforcer
    set :session_secret, ENV['MSG_KEY']
  end

  GOOGLE_API = 'https://accounts.google.com/o/oauth2/auth'
  GOOGLE_OAUTH = "?response_type=code&client_id=#{ENV['CLIENT_ID']}"

  get '/' do
    slim :index
  end

  get '/oauth2callback_gmail/?' do
    result = HTTParty.post(
      'https://www.googleapis.com/oauth2/v3/token',
      body: { code: params['code'], client_id: ENV['CLIENT_ID'],
              client_secret: ENV['CLIENT_SECRET'],
              grant_type: 'authorization_code',
              redirect_uri: "#{request.base_url}/oauth2callback_gmail" },
      headers: { 'Accept' => 'application/json' }
    )
    result.to_s
  end

  # Get course list
  # get '/course_list/?' do
  #   url = CANVAS + 'courses'
  #   headers = { authorization: ('Bearer ' + ENV['ACCESS_TOKEN']) }
  #   (HTTParty.get url, headers: headers).to_s
  # end
end
