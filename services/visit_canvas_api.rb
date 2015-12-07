# Service Object that calls the Canvas LMS API resource
class VisitCanvasAPI
  def initialize(url, canvas_token)
    @url = url
    @headers = { 'authorization' => ('Bearer ' + canvas_token) }
  end

  def all_the_data(results, parsed_results, page = 1)
    links = results.headers.to_hash['link']
    return parsed_results if links.nil?
    while links[0].include?('rel="next"')
      page += 1
      results = (HTTParty.get "#{@url}?page=#{page}", headers: @headers)
      parsed_results += JSON.parse(results.to_json)
      links = results.headers.to_hash['link']
    end
    parsed_results
  end

  def call
    results = (HTTParty.get "#{@url}?page=1", headers: @headers)
    parsed_results = JSON.parse(results.to_json)
    if parsed_results.is_a?(Array)
      parsed_results = all_the_data(results, parsed_results)
    end
    parsed_results.to_json
  end
end
