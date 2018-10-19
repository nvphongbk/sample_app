class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    check_user user
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end

  def check_session user
    if params[:session][:remember_me] == Settings.sessions.check_session
      remember user
    else
      forget user
    end
  end

  def check_user user
    if user&.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        check_session user
        redirect_back_or user
      else
        message = t "controllers.sessions.check_mail"
        flash[:warning] = message
        redirect_to root_path
      end
    else
      flash.now[:danger] = t "controllers.sessions.invalid"
      render :new
    end
  end
end
