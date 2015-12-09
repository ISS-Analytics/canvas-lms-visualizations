# Helper module to dealing with tokens
module AppTokenHelper
  def you_shall_not_pass!(access_key)
    merlin = YouShallNotPass.new(@current_teacher, access_key).call
    return merlin if merlin
    flash[:error] = 'You do not own this token!'
    redirect '/tokens'
  end
end
