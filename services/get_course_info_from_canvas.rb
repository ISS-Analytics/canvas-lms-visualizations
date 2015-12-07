# Service Object that gets course info from Canvas API
# Depends on what info is request, this covers a number of API calls
class GetCourseInfoFromCanvas
  def initialize(params_for_api)
    @url = params_for_api.canvas_api + 'courses/' + params_for_api.course_id +
           "/#{params_for_api.data}"
    @canvas_token = params_for_api.canvas_token
  end

  def call
    visit_canvas = VisitCanvasAPI.new(@url, @canvas_token)
    visit_canvas.call
  end
end
