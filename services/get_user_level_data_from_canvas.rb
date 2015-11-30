# Service Object that gets user level data from Canvas API
class GetUserLevelDataFromCanvas
  def initialize(canvas_api, canvas_token, course_id, data)
    @canvas_api = canvas_api
    @canvas_token = canvas_token
    @course_id = course_id
    @data = data
  end

  def call
    student_ids.compact.map do |id|
      Concurrent::Future.new do
        { "#{id}" => GetCourseAnalyticsFromCanvas.new(
          @canvas_api, @canvas_token, @course_id,
          "/#{@data}/#{id}/activity").call }
      end; end.map(&:execute).map(&:value).to_json
  end

  def student_ids
    persons = GetCourseInfoFromCanvas.new(@canvas_api, @canvas_token,
                                          @course_id, 'enrollments').call
    JSON.parse(persons, quirks_mode: true).map do |person|
      person['user_id'] if person['type'] == 'StudentEnrollment'
    end.compact
  end
end
