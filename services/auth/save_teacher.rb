# Object to save teacher
class SaveTeacher
  def initialize(email)
    @email = email
  end

  def call
    teacher = Teacher.new(email: @email)
    if teacher.save
      StoreEmailAsSessionVar.new(@email).call
    else
      fail('Could not create new teacher')
    end
  end
end
