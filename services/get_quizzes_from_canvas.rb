# Service Object that gets quiz data from Canvas API
class GetQuizzesFromCanvas
  def initialize(canvas_api, canvas_token, course_id, data)
    @canvas_api = canvas_api
    @canvas_token = canvas_token
    @course_id = course_id
    @data = data
  end

  def call
    quiz_list.map do |quiz|
      Concurrent::Future.new do
        { quiz['title'] => GetCourseInfoFromCanvas.new(
          @canvas_api, @canvas_token, @course_id,
          "/#{@data}/#{quiz['id']}/statistics").call }
      end; end.map(&:execute).map(&:value).to_json
  end

  def quiz_list
    quizzes = GetCourseInfoFromCanvas.new(@canvas_api, @canvas_token,
                                          @course_id, @data).call
    JSON.parse(quizzes)
  end
end
