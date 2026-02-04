class TeamInvitesController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :require_team

  before_action :set_team
  before_action :redirect_if_already_member, only: :show

  def show
    @user = User.new
  end

  def create
    if authenticated?
      join_existing_user
    else
      join_new_user
    end
  end

  private

  def set_team
    @team = Team.find_by!(slug: params[:slug], invite_code: params[:invite_code])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Invalid invite link"
  end

  def redirect_if_already_member
    return unless authenticated? && @team.member?(Current.user)

    redirect_to root_path, notice: "You're already a member of this team"
  end

  def join_existing_user
    @team.add_member(Current.user)
    session[:current_team_id] = @team.id
    redirect_to root_path, notice: "You've joined #{@team.name}"
  end

  def join_new_user
    @user = User.new(user_params)

    if @user.save
      @team.add_member(@user)
      start_new_session_for @user
      session[:current_team_id] = @team.id
      redirect_to root_path, notice: "Welcome to #{@team.name}!"
    else
      render :show, status: :unprocessable_entity
    end
  end

  def user_params
    params.require(:user).permit(:name, :email_address, :password, :password_confirmation, :avatar)
  end
end
