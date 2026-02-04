class MembershipsController < ApplicationController
  before_action :set_team
  before_action :require_user_management
  before_action :set_membership, only: [ :update, :destroy ]

  def create
    user = User.find_by(email_address: membership_params[:email_address])

    if user.nil?
      redirect_to team_path(@team), alert: "User not found with that email"
      return
    end

    if @team.member?(user)
      redirect_to team_path(@team), alert: "User is already a member"
      return
    end

    membership = @team.add_member(user, role: membership_params[:role] || :member)

    if membership.persisted?
      redirect_to team_path(@team), notice: "#{user.name} added to team"
    else
      redirect_to team_path(@team), alert: "Failed to add member"
    end
  end

  def update
    if @membership.user == @team.owner && membership_params[:role] != "owner"
      redirect_to team_path(@team), alert: "Cannot change the owner's role"
      return
    end

    if @membership.update(role: membership_params[:role])
      redirect_to team_path(@team), notice: "Role updated"
    else
      redirect_to team_path(@team), alert: "Failed to update role"
    end
  end

  def destroy
    if @membership.owner?
      redirect_to team_path(@team), alert: "Cannot remove the team owner"
      return
    end

    @membership.destroy
    redirect_to team_path(@team), notice: "Member removed"
  end

  private

  def set_team
    @team = Current.user.teams.find(params[:team_id])
  end

  def set_membership
    @membership = @team.memberships.find(params[:id])
  end

  def require_user_management
    return if Current.membership&.can_manage_users?
    redirect_to team_path(@team), alert: "You don't have permission to manage members"
  end

  def membership_params
    # brakeman:disable:PermitAttributes - role assignment is protected by require_user_management
    params.require(:membership).permit(:email_address, :role)
  end
end
