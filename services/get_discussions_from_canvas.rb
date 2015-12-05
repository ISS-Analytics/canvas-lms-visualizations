# Service Object that gets discussion data from Canvas API
class GetDiscussionsFromCanvas
  def initialize(data_for_api)
    @canvas_api = data_for_api.canvas_api
    @canvas_token = data_for_api.canvas_token
    @course_id = data_for_api.course_id
    @data = data_for_api.data
  end

  def call
    discussion_list.map do |discussion|
      Concurrent::Future.new do
        data_for_api = DataForApiCall.new(
          @canvas_api, @canvas_token, @course_id,
          "/#{@data}/#{discussion['id']}/view"
        )
        GetCourseInfoFromCanvas.new(data_for_api).call
      end; end.map(&:execute).map(&:value).to_json
  end

  def discussion_list
    data_for_api = DataForApiCall.new(
      @canvas_api, @canvas_token, @course_id, @data
    )
    discussions = GetCourseInfoFromCanvas.new(data_for_api).call
    JSON.parse(discussions)
  end
end
