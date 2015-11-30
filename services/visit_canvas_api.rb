# Service Object that calls the Canvas LMS API resource
class VisitCanvasAPI
  def initialize(url, canvas_token)
    @url = url
    @canvas_token = canvas_token
  end

  def call
    headers = { 'authorization' => ('Bearer ' + @canvas_token) }
    (HTTParty.get @url, headers: headers).to_json
  end
end
