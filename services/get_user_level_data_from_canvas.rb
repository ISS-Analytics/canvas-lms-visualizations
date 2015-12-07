# Service Object that gets user level data from Canvas API
class GetUserLevelDataFromCanvas
  def initialize(params_for_api)
    @canvas_api = params_for_api.canvas_api
    @canvas_token = params_for_api.canvas_token
    @course_id = params_for_api.course_id
    @data = params_for_api.data
  end

  def call
    student_ids.compact.map do |id|
      Concurrent::Future.new do
        params_for_api = ParamsForCanvasApi.new(
          @canvas_api, @canvas_token, @course_id, "/#{@data}/#{id}/activity"
        )
        { "#{id}" => GetCourseAnalyticsFromCanvas.new(params_for_api).call }
      end; end.map(&:execute).map(&:value).to_json
  end

  def student_ids
    params_for_api = ParamsForCanvasApi.new(
      @canvas_api, @canvas_token, @course_id, 'enrollments'
    )
    persons = GetCourseInfoFromCanvas.new(params_for_api).call
    JSON.parse(persons, quirks_mode: true).map do |person|
      person['user_id'] if person['type'] == 'StudentEnrollment'
    end.compact
  end
end
