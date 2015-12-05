# Helper module for app, handling API
module AppAPIHelper
  def service_object_traffic_controller(params, data_for_api)
    if params['data'] == 'discussion_topics'
      GetDiscussionsFromCanvas.new(data_for_api)
    elsif params['data'] == 'quizzes'
      GetQuizzesFromCanvas.new(data_for_api)
    elsif params['data'] == 'users'
      GetUserLevelDataFromCanvas.new(data_for_api)
    elsif params['no_analytics']
      GetCourseInfoFromCanvas.new(data_for_api)
    else GetCourseAnalyticsFromCanvas.new(data_for_api)
    end
  end
end
