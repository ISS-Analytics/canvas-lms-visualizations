require 'sinatra/base'
require 'config_env'
require 'rack/ssl-enforcer'
require 'httparty'
require 'slim'
require 'slim/include'
require 'rack-flash'
require 'chartkick'
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
  COOKIE_VALUE = 13..-1

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)

  configure :development, :test do
    set :root, 'http://localhost:9292'
  end

  configure :production do
    use Rack::SslEnforcer
    set :session_secret, ENV['MSG_KEY']
    set :root, 'https://canvas-viz.herokuapp.com'
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
        end; end
    end
  end

  before do
    @current_teacher = GetTeacherInSessionVar.new(session[:auth_token]).call
    @token_set = GetPasswordInSessionVar.new(session[:unleash_token]).call
  end

  get '/' do
    slim :index
  end

  get '/oauth2callback_gmail/?' do
    access_token = CallbackGmail.new(params, request).call
    email = GoogleTeacherEmail.new(access_token).call
    session[:auth_token] =
      if find_teacher(email)
        StoreEmailAsSessionVar.new(email).call
      else
        SaveTeacher.new(email).call
      end
    redirect '/welcome'
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
    password = params['password']
    teacher = VerifyPassword.new(@current_teacher, password).call
    if teacher == 'no password found'
      flash[:error] = 'You\'re yet to save a password.'
      redirect '/welcome'
    elsif teacher.nil?
      flash[:error] = 'Wrong Password'
      redirect '/welcome'
    end
    session[:unleash_token] =
      SavePasswordToSessionVar.new(password, teacher.token_salt).call
    redirect '/tokens'
  end

  post '/new_teacher', auth: [:teacher] do
    create_password_form = CreatePasswordForm.new(params)
    if create_password_form.valid?
      session[:unleash_token] = SaveTeacherPassword.new(
        @current_teacher.email, params['password']
      ).call
      redirect '/tokens'
    else
      flash[:error] = "#{create_password_form.error_message}."
      redirect '/welcome'
    end
  end

  get '/tokens/?', auth: [:teacher, :token_set] do
    tokens = ListTokens.new(@current_teacher, @token_set).call
    slim :tokens, locals: { tokens: tokens }
  end

  post '/tokens/?', auth: [:teacher, :token_set] do
    save_token_form = SaveTokenForm.new(params)
    if save_token_form.valid?
      result = SaveToken.new(@current_teacher, @token_set, params).call
      if result.include?('saved')
        flash[:notice] = "#{result}"
      else flash[:error] = "#{result}"
      end
    else
      flash[:error] = "#{save_token_form.error_message}."
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
    if DeleteToken.new(token).call
      flash[:notice] = 'Successfully deleted!'
    else
      flash[:error] = 'This is a strange one'
    end
    redirect '/tokens'
  end

  get '/tokens/:access_key/:course_id/dashboard/?',
      auth: [:teacher, :token_set] do
    cookie = env['HTTP_COOKIE'][COOKIE_VALUE]
    cookie = { 'rack.session' => cookie }
    url = "#{settings.root}/tokens/#{params[:access_key]}/#{params[:course_id]}"
    activity_url = "#{url}/activity?api_mode=true"
    assignment_url = "#{url}/assignments?api_mode=true"
    discussion_url = "#{url}/discussion_topics?no_analytics=true&api_mode=true"
    student_summaries_url = "#{url}/student_summaries?api_mode=true"
    activity = HTTParty.get activity_url, cookies: cookie
    assignment = HTTParty.get assignment_url, cookies: cookie
    discussions = HTTParty.get discussion_url, cookies: cookie
    student_summaries = HTTParty.get student_summaries_url, cookies: cookie
    slim :dashboard, locals: {
      activities: JSON.parse(activity, quirks_mode: true),
      assignments: JSON.parse(assignment, quirks_mode: true),
      discussions_list: JSON.parse(discussions, quirks_mode: true),
      student_summaries: JSON.parse(student_summaries, quirks_mode: true)
    }
  end

  get '/tokens/:access_key/:course_id/:data/?',
      auth: [:teacher, :token_set] do
    token = you_shall_not_pass!(params['access_key'])
    params_for_api = ParamsForCanvasApi.new(
      token.canvas_api(@token_set), token.canvas_token(@token_set),
      params['course_id'], params['data']
    )
    service_object = service_object_traffic_controller(params, params_for_api)
    result = service_object.call
    return result if params['api_mode'] == 'true'
    slim :"#{params['data']}",
         locals: { data: JSON.parse(result, quirks_mode: true) }
  end
end
