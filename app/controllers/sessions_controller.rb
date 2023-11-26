class SessionsController < ApplicationController
  protect_from_forgery
  def create
    user_info = request.env['omniauth.auth']
    uid = user_info&.uid
    email = user_info&.info&.email
    uid = user_info&.uid
    raw_info = user_info&.extra&.raw_info
    user_name = raw_info&.preferred_username
    @user = User.find_or_initialize_by(user_name:, email:)
    if @user.persisted?
      @user.update!(uid: uid)
      session[:your_session_key] = @user.id
      redirect_to @user
    else
      flash[:alert] = '新規登録を先にお済ませください'
      redirect_to root_path
    end
  end

  def delete
    session[:your_session_key] = nil
    redirect_to top_path
  end
end
