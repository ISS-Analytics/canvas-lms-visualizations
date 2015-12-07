# Value object that goes to canvas api calls
class ParamsForCanvasApi
  attr_accessor :canvas_api, :canvas_token, :course_id, :data

  def initialize(canvas_api, canvas_token, course_id, data)
    @canvas_api = canvas_api
    @canvas_token = canvas_token
    @course_id = course_id
    @data = data
  end
end
