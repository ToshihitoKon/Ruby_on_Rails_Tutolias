module SessionsHelper

  # login to argumented user
  def log_in(user)
    session[:user_id] = user.id
  end

  # return current login user
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # return login status (boolean)
  def logged_in?
    !current_user.nil?
  end
end
