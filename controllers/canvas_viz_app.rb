require 'sinatra/base'
require 'config_env'
require 'rack/ssl-enforcer'
require 'httparty'
require 'slim'
require 'slim/include'
require 'rack-flash'
require 'chartkick'
# require 'groupdate'
require 'ap'
require 'concurrent'
require 'jwt'
require 'json'
require 'tilt/kramdown'

configure :development, :test do
  require 'hirb'
  Hirb.enable
  absolute_path = File.absolute_path './config/config_env.rb'
  ConfigEnv.path_to_config(absolute_path)
end

# Visualizations for Canvas LMS Classes
class CanvasVisualizationApp < Sinatra::Base
  include AppLoginHelper, AppAPIHelper, AppTokenHelper
  enable :logging
  use Rack::MethodOverride

  GOOGLE_OAUTH = 'https://accounts.google.com/o/oauth2/auth'
  GOOGLE_PARAMS = "?response_type=code&client_id=#{ENV['CLIENT_ID']}"

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)
  set :env_dir, File.expand_path('../../config', __FILE__)

  configure :production do
    use Rack::SslEnforcer
    set :session_secret, ENV['MSG_KEY']
  end

  configure do
    use Rack::Session::Pool, secret: settings.session_secret
    use Rack::Flash, sweep: true
  end

  register do
    def auth(*types)
      condition do
        if (types.include? :teacher) && !@current_teacher
          flash[:error] = 'You must be logged in to view that page'
          redirect '/'
        elsif (types.include? :token_set) && !@token_set
          flash[:error] = 'You must enter a password to view that page'
          redirect '/welcome'
        end
      end
    end
  end

  before do
    @current_teacher = find_user_by_token(session[:auth_token])
    @token_set = avail_tokens_for_user(session[:unleash_token])
  end

  get '/' do
    slim :index
  end

  get '/oauth2callback_gmail/?' do
    access_token = CallbackGmail.new(params, request).call
    email = GoogleTeacherEmail.new(access_token).call
    find_teacher(email) ? login_teacher(email) : register_teacher(email)
  end

  get '/logout/?' do
    session[:auth_token] = nil
    session[:unleash_token] = nil
    flash[:notice] = 'Logged out'
    redirect '/'
  end

  get '/welcome/?', auth: [:teacher] do
    slim :welcome
  end

  post '/retrieve', auth: [:teacher] do
    retrieve(params['password'])
  end

  post '/new_teacher', auth: [:teacher] do
    if params['password'] == params['password_confirm']
      create_password(params['password'])
    else
      flash[:error] = 'Please write the same password twice'
      redirect '/welcome'
    end
  end

  get '/tokens/?', auth: [:teacher, :token_set] do
    tokens = list_tokens
    slim :tokens, locals: { tokens: tokens }
  end

  post '/tokens/?', auth: [:teacher, :token_set] do
    result = save_token(params['token'], params['url'])
    if result.include?('saved')
      flash[:notice] = "#{result}"
    else flash[:error] = "#{result}"
    end
    redirect '/tokens'
  end

  get '/tokens/:access_key/?', auth: [:teacher, :token_set] do
    token = you_shall_not_pass!(params['access_key'])
    courses = GetCoursesFromCanvas.new(token.canvas_api(@token_set),
                                       token.canvas_token(@token_set))
    courses = courses.call
    slim :courses, locals: { courses: JSON.parse(courses),
                             token: params['access_key'] }
  end

  delete '/tokens/:access_key/?', auth: [:teacher, :token_set] do
    token = you_shall_not_pass!(params['access_key'])
    delete_token(token)
    redirect '/tokens'
  end

  get '/tokens/:access_key/:course_id/:data/?',
      auth: [:teacher, :token_set] do
    token = you_shall_not_pass!(params['access_key'])
    data_for_api = DataForApiCall.new(
      token.canvas_api(@token_set), token.canvas_token(@token_set),
      params['course_id'], params['data']
    )
    service_object = service_object_traffic_controller(params, data_for_api)
    result = service_object.call
    slim :"#{params['data']}",
         locals: { data: JSON.parse(result, quirks_mode: true) }
  end
end
