# Helper module for app, handling API
module AppAPIHelper
  def service_object_traffic_controller(params, params_for_api)
    if params['data'] == 'discussion_topics'
      GetDiscussionsFromCanvas.new(params_for_api)
    elsif params['data'] == 'quizzes'
      GetQuizzesFromCanvas.new(params_for_api)
    elsif params['data'] == 'users'
      GetUserLevelDataFromCanvas.new(params_for_api)
    elsif params['no_analytics']
      GetCourseInfoFromCanvas.new(params_for_api)
    else GetCourseAnalyticsFromCanvas.new(params_for_api)
    end
  end
end
