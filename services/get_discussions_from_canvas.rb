# Service Object that gets discussion data from Canvas API
class GetDiscussionsFromCanvas
  def initialize(params_for_api)
    @canvas_api = params_for_api.canvas_api
    @canvas_token = params_for_api.canvas_token
    @course_id = params_for_api.course_id
    @data = params_for_api.data
  end

  def call
    discussion_list.map do |discussion|
      Concurrent::Future.new do
        params_for_api = ParamsForCanvasApi.new(
          @canvas_api, @canvas_token, @course_id,
          "/#{@data}/#{discussion['id']}/view"
        )
        GetCourseInfoFromCanvas.new(params_for_api).call
      end; end.map(&:execute).map(&:value).to_json
  end

  def discussion_list
    params_for_api = ParamsForCanvasApi.new(
      @canvas_api, @canvas_token, @course_id, @data
    )
    discussions = GetCourseInfoFromCanvas.new(params_for_api).call
    JSON.parse(discussions)
  end
end
