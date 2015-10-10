require 'sinatra'
require 'config_env'
require 'rack/ssl-enforcer'
require 'httparty'

configure :development, :test do
  ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
end

# Custom ~'wrapper' for the Canvas LMS API
class CanvasLmsAPI < Sinatra::Base
  configure :production do
    use Rack::SslEnforcer
    set :session_secret, ENV['MSG_KEY']
  end

  CANVAS = 'https://n.acme.instructure.com/api/v1/'

  get '/' do
    'Hello'
  end

  # Get course list
  get '/course_list/?' do
    url = CANVAS + 'courses'
    headers = { authorization: ('Bearer ' + ENV['ACCESS_TOKEN']) }
    (HTTParty.get url, headers: headers).to_s
  end
end
