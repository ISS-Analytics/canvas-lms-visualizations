# Object to save teacher password
class SaveTeacherPassword
  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    DeleteAllTokens.new(@email).call
    teacher = Teacher.find_by_email(@email)
    teacher.password = @password
    if teacher.save
      SavePasswordToSessionVar.new(@password, teacher.token_salt).call
    else
      fail('This is a weird one.')
    end
  end
end
