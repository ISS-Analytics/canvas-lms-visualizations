# Helper module for app, handling API
module AppAPIHelper
  def service_object_traffic_controller(params, arr)
    if params['data'] == 'discussion_topics'
      GetDiscussionsFromCanvas.new(*arr)
    elsif params['data'] == 'quizzes'
      GetQuizzesFromCanvas.new(*arr)
    elsif params['data'] == 'users'
      GetUserLevelDataFromCanvas.new(*arr)
    elsif params['no_analytics']
      GetCourseInfoFromCanvas.new(*arr)
    else GetCourseAnalyticsFromCanvas.new(*arr)
    end
  end
end
