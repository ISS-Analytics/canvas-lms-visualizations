# Service Object that gets user level data from Canvas API
class GetUserLevelDataFromCanvas
  def initialize(data_for_api)
    @canvas_api = data_for_api.canvas_api
    @canvas_token = data_for_api.canvas_token
    @course_id = data_for_api.course_id
    @data = data_for_api.data
  end

  def call
    student_ids.compact.map do |id|
      Concurrent::Future.new do
        data_for_api = DataForApiCall.new(
          @canvas_api, @canvas_token, @course_id, "/#{@data}/#{id}/activity"
        )
        { "#{id}" => GetCourseAnalyticsFromCanvas.new(data_for_api).call }
      end; end.map(&:execute).map(&:value).to_json
  end

  def student_ids
    data_for_api = DataForApiCall.new(
      @canvas_api, @canvas_token, @course_id, 'enrollments'
    )
    persons = GetCourseInfoFromCanvas.new(data_for_api).call
    JSON.parse(persons, quirks_mode: true).map do |person|
      person['user_id'] if person['type'] == 'StudentEnrollment'
    end.compact
  end
end
