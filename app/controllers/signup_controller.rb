class SignupController < ApplicationController
  allow_unauthenticated_access

  skip_before_action :require_team
  before_action :enforce_tenant_limit

  def new
    @signup = Signup.new
  end

  def create
    @signup = Signup.new(signup_params)

    if @signup.save
      start_new_session_for @signup.user
      redirect_to root_path, notice: "Account created successfully. Welcome to Vibebrew!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def enforce_tenant_limit
    redirect_to root_path unless Team.accepting_signups?
  end

  def signup_params
    params.require(:signup).permit(:name, :email_address, :password, :password_confirmation, :avatar)
  end
end
