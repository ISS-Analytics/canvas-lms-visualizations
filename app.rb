require 'sinatra'
require 'config_env'
require 'rack/ssl-enforcer'
require 'httparty'
require 'slim'
require 'slim/include'
require 'rack-flash'
require_relative './model/teacher'
require_relative './model/token'
require_relative './helpers/app_helpers'

configure :development, :test do
  require 'hirb'
  ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
  Hirb.enable
end

# Visualizations for Canvas LMS Classes
class CanvasLmsAPI < Sinatra::Base
  include AppHelper
  enable :logging

  GOOGLE_OAUTH = 'https://accounts.google.com/o/oauth2/auth'
  GOOGLE_PARAMS = "?response_type=code&client_id=#{ENV['CLIENT_ID']}"

  configure :production do
    use Rack::SslEnforcer
    set :session_secret, ENV['MSG_KEY']
  end

  configure do
    use Rack::Session::Cookie, secret: settings.session_secret
    use Rack::Flash, sweep: true
  end

  register do
    def auth(*types)
      condition do
        if (types.include? :teacher) && !@current_teacher
          session[:redirect] = request.env['REQUEST_URI']
          flash[:error] = 'You must be logged in to view that page'
          redirect '/'
        end
      end
    end
  end

  before do
    @current_teacher = find_user_by_token(session[:auth_token])
  end

  get '/' do
    slim :index
  end

  get '/login/?' do
    login_gmail if params['site'] == 'gmail'
  end

  get '/oauth2callback_gmail/?' do
    callback_json = callback_gmail(params).to_json
    access_token = JSON.parse(callback_json)['access_token']
    email = teacher_email(access_token)
    find_teacher(email) ? login_teacher(email) : register_teacher(email)
  end

  get '/logout' do
    session[:auth_token] = nil
    flash[:notice] = 'Logged out'
    redirect '/'
  end

  get '/welcome', auth: [:teacher] do
    'Hello!!!!!!!!'
  end
end
