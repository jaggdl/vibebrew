class SetupController < ApplicationController
  allow_unauthenticated_access

  before_action :require_no_users

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: "Account created successfully. Welcome to VibeCoffee!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def require_no_users
    redirect_to root_path if User.exists?
  end

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
