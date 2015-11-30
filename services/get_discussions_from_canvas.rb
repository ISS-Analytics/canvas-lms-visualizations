# Service Object that gets discussion data from Canvas API
class GetDiscussionsFromCanvas
  def initialize(canvas_api, canvas_token, course_id, data)
    @canvas_api = canvas_api
    @canvas_token = canvas_token
    @course_id = course_id
    @data = data
  end

  def call
    discussion_list.map do |discussion|
      Concurrent::Future.new do
        GetCourseInfoFromCanvas.new(@canvas_api, @canvas_token, @course_id,
                                    "/#{@data}/#{discussion['id']}/view").call
      end; end.map(&:execute).map(&:value).to_json
  end

  def discussion_list
    discussions = GetCourseInfoFromCanvas.new(@canvas_api, @canvas_token,
                                              @course_id, @data).call
    JSON.parse(discussions)
  end
end
