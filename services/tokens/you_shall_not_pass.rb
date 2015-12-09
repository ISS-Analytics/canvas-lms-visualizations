# The Token GateKeeper
class YouShallNotPass
  def initialize(current_teacher, access_key)
    @tokens = Token.where(email: current_teacher.email)
    @access_key = access_key
  end

  def call
    @tokens.select do |token|
      token.access_key.include? @access_key
    end[0]
  end
end
