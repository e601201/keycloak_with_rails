class SessionsController < ApplicationController
  protect_from_forgery
  def create
    user_info = request.env['omniauth.auth']
    uid = user_info&.uid
    email = user_info&.info&.email
    @user = User.find_or_create_by(email:, uid:)
    if @user.persisted?
      session[:user_id] = @user.id
      redirect_to user_path
    else
      redirect_to root_path
    end
  end

  def delete
    session[:user_id] = nil
    redirect_to top_path
  end
end
