class ApplicationController < ActionController::Base
  helper_method :current_user

  protected

  def require_authentication
    redirect_to login_path if current_user.nil?
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    else
      @current_user = nil
    end
  end
end
