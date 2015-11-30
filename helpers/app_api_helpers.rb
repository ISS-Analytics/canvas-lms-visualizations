# Helper module for app, handling API
module AppAPIHelper
  def result_route(params, arr)
    if params['data'] == 'discussion_topics'
      all_discussion(*arr)
    elsif params['data'] == 'quizzes'
      all_quiz(*arr)
    elsif params['data'] == 'users'
      user_by_user(*arr)
    elsif params['no_analytics']
      GetCourseInfoFromCanvas.new(*arr).call
    else GetCourseAnalyticsFromCanvas.new(*arr).call
    end
  end

  def all_discussion(canvas_api, canvas_token, course_id, data)
    discussions = GetCourseInfoFromCanvas.new(canvas_api, canvas_token,
                                              course_id, data).call
    discussions = JSON.parse(discussions)
    discussions.map do |discussion|
      Concurrent::Future.new do
        GetCourseInfoFromCanvas.new(canvas_api, canvas_token, course_id,
                                    "/#{data}/#{discussion['id']}/view").call
      end; end.map(&:execute).map(&:value).to_json
  end

  def all_quiz(canvas_api, canvas_token, course_id, data)
    quizzes = GetCourseInfoFromCanvas.new(canvas_api, canvas_token, course_id,
                                          data).call
    quizzes = JSON.parse(quizzes)
    quizzes.map do |quiz|
      Concurrent::Future.new do
        { quiz['title'] => GetCourseInfoFromCanvas.new(
          canvas_api, canvas_token, course_id,
          "/#{data}/#{quiz['id']}/statistics").call }
      end; end.map(&:execute).map(&:value).to_json
  end

  def user_by_user(canvas_api, canvas_token, course_id, data)
    persons = GetCourseInfoFromCanvas.new(canvas_api, canvas_token, course_id,
                                          'enrollments').call
    student_ids = JSON.parse(persons, quirks_mode: true).map do |person|
      person['user_id'] if person['type'] == 'StudentEnrollment'
    end
    student_ids.compact.map do |id|
      Concurrent::Future.new do
        { "#{id}" => GetCourseAnalyticsFromCanvas.new(
          canvas_api, canvas_token, course_id, "/#{data}/#{id}/activity").call }
      end; end.map(&:execute).map(&:value).to_json
  end
end
