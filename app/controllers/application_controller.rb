class ApplicationController < ActionController::Base
  helper_method :current_user
  helper_method :user_signed_in?
  def current_user
    @current_user ||= User.find(session[:your_session_key]) if session[:your_session_key].present?
  end

  def user_signed_in?
    !!current_user
  end
end
