require 'sinatra'
require 'config_env'
require 'rack/ssl-enforcer'
require 'httparty'
require 'slim'
require 'slim/include'
require 'rack-flash'
require 'chartkick'
require 'groupdate'
require 'ap'
require 'concurrent'
require_relative './model/teacher'
require_relative './model/token'
require_relative './helpers/app_login_helpers'
require_relative './helpers/app_api_helpers'

configure :development, :test do
  require 'hirb'
  ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
  Hirb.enable
end

# Visualizations for Canvas LMS Classes
class CanvasLmsAPI < Sinatra::Base
  include AppLoginHelper, AppAPIHelper
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

  get '/oauth2callback_gmail/?' do
    callback_json = callback_gmail(params).to_json
    access_token = JSON.parse(callback_json)['access_token']
    email = teacher_email(access_token)
    find_teacher(email) ? login_teacher(email) : register_teacher(email)
  end

  get '/logout/?' do
    session[:auth_token] = nil
    flash[:notice] = 'Logged out'
    redirect '/'
  end

  get '/tokens/?', auth: [:teacher] do
    tokens = list_tokens
    slim :tokens, locals: { tokens: tokens }
  end

  post '/tokens/?', auth: [:teacher] do
    result = save_token(params['token'], params['url'])
    if result.include?('saved')
      flash[:notice] = "#{result}"
    else flash[:error] = "#{result}"
    end
    redirect '/tokens'
  end

  get '/tokens/:canvas_token_display/?', auth: [:teacher] do
    token = cross_tokens(params['canvas_token_display'])
    courses = courses(token.canvas_api, token.canvas_token)
    slim :courses, locals: { courses: JSON.parse(courses),
                             token: params['canvas_token_display'] }
  end

  get '/tokens/:canvas_token_display/:course_id/:data/?', auth: [:teacher] do
    token = cross_tokens(params['canvas_token_display'])
    arr = [token.canvas_api, token.canvas_token, params['course_id'],
           params['data']]
    result = result(params, arr)
    slim :"#{params['data']}",
         locals: { data: JSON.parse(result, quirks_mode: true) }
  end
end
