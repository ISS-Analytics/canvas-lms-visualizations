# Object to verify password provided by user
class VerifyPassword
  def initialize(current_teacher, password)
    @current_teacher = current_teacher
    @password = password
  end

  def call
    return 'no password found' if @current_teacher.hashed_password.nil?
    Teacher.authenticate!(@current_teacher.email, @password)
  end
end
