# Service Object that gets quiz data from Canvas API
class GetQuizzesFromCanvas
  def initialize(data_for_api)
    @canvas_api = data_for_api.canvas_api
    @canvas_token = data_for_api.canvas_token
    @course_id = data_for_api.course_id
    @data = data_for_api.data
  end

  def call
    quiz_list.map do |quiz|
      Concurrent::Future.new do
        data_for_api = DataForApiCall.new(
          @canvas_api, @canvas_token, @course_id,
          "/#{@data}/#{quiz['id']}/statistics"
        )
        { quiz['title'] => GetCourseInfoFromCanvas.new(data_for_api).call }
      end; end.map(&:execute).map(&:value).to_json
  end

  def quiz_list
    data_for_api = DataForApiCall.new(
      @canvas_api, @canvas_token, @course_id, @data
    )
    quizzes = GetCourseInfoFromCanvas.new(data_for_api).call
    JSON.parse(quizzes)
  end
end
