module SessionsHelper

  # login to argumented user
  def log_in(user)
    session[:user_id] = user.id
  end

  # permanent user session
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # return current login user
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif (user_id = cookies.signed[:user_id])
      user User.find_by(id: cookies.signed[:user_id])
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # return login status (boolean)
  def logged_in?
    !current_user.nil?
  end

  # remove permanent session
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # logout current user
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
end
