GOOGLE_API = 'https://www.googleapis.com/oauth2/'
ACCESS_TOKEN = 'access_token'
EMAIL = 'email'

# Service object to get access token from Google
class CallbackGmail
  def initialize(params, request)
    @url = "#{GOOGLE_API}v3/token"
    @headers = { 'Accept' => 'application/json' }
    @body = {
      code: params['code'], grant_type: 'authorization_code',
      client_id: ENV['CLIENT_ID'], client_secret: ENV['CLIENT_SECRET'],
      redirect_uri: "#{request.base_url}/oauth2callback_gmail"
    }
  end

  def call
    callback_json = HTTParty.post(@url, body: @body, headers: @headers).to_json
    JSON.parse(callback_json)[ACCESS_TOKEN]
  end
end

# Service object to get teacher verified email from Google
class GoogleTeacherEmail
  def initialize(access_token)
    @url = "#{GOOGLE_API}v2/userinfo"
    @headers = { 'authorization' => "Bearer #{access_token}" }
  end

  def call
    results_json = HTTParty.get(@url, headers: @headers).to_json
    JSON.parse(results_json)[EMAIL]
  end
end
