require 'sinatra'
require 'config_env'
require 'rack/ssl-enforcer'

configure :development, :test do
  ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
end

# Custom ~'wrapper' for the Canvas LMS API
class CanvasLmsAPI < Sinatra::Base
  configure :production do
    use Rack::SslEnforcer
    set :session_secret, ENV['MSG_KEY']
  end

  get '/' do
    'Hello'
  end
end
