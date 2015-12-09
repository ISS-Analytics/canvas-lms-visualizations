# Helper module for app, handling login
module AppLoginHelper
  # TODO: Investigate query objects???
  def find_teacher(email)
    Teacher.find_by_email(email)
  end
end
