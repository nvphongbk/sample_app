class PasswordResetsController < ApplicationController
  before_action :load_user, :valid_user, :check_expiration,
    only: %i(edit update)

  def new; end

  def create
    if !@user
      flash.now[:danger] = t "controllers.password_resets.mail_not_found"
      render :new
    else
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "controllers.password_resets.mess_send_mail"
      redirect_to root_url
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password,
        t("controllers.password_resets.email_not_empty"))
      render :edit
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = t "controllers.password_resets.password_has_been_reset"
      redirect_to @user
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def load_user
    @user = User.find_by email: params[:email]
  end

  def valid_user
    unless @user&.activated? &&
           @user.authenticated?(:reset, params[:id])
      redirect_to root_url
    end
  end

  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = t "controllers.password_resets.password_reset_expired"
    redirect_to new_password_reset_url
  end
end
