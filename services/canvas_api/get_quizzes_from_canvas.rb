# Service Object that gets quiz data from Canvas API
class GetQuizzesFromCanvas
  def initialize(params_for_api)
    @canvas_api = params_for_api.canvas_api
    @canvas_token = params_for_api.canvas_token
    @course_id = params_for_api.course_id
    @data = params_for_api.data
  end

  def call
    quiz_list.map do |quiz|
      Concurrent::Future.new do
        params_for_api = ParamsForCanvasApi.new(
          @canvas_api, @canvas_token, @course_id,
          "/#{@data}/#{quiz['id']}/statistics"
        )
        { quiz['title'] => GetCourseInfoFromCanvas.new(params_for_api).call }
      end; end.map(&:execute).map(&:value).to_json
  end

  def quiz_list
    params_for_api = ParamsForCanvasApi.new(
      @canvas_api, @canvas_token, @course_id, @data
    )
    quizzes = GetCourseInfoFromCanvas.new(params_for_api).call
    JSON.parse(quizzes)
  end
end
