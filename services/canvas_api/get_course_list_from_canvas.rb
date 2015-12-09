# Service Object that gets list of courses from Canvas API
class GetCoursesFromCanvas
  def initialize(canvas_api, canvas_token)
    @url = canvas_api + 'courses'
    @canvas_token = canvas_token
  end

  def call
    visit_canvas = VisitCanvasAPI.new(@url, @canvas_token)
    visit_canvas.call
  end
end
