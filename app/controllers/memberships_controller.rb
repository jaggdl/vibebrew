class MembershipsController < ApplicationController
  before_action :set_team
  before_action :require_user_management
  before_action :set_membership, only: [ :update, :destroy ]

  def create
    user = User.find_by(email_address: membership_params[:email_address])

    if user.nil?
      redirect_to team_index_path, alert: "User not found with that email"
      return
    end

    if @team.member?(user)
      redirect_to team_index_path, alert: "User is already a member"
      return
    end

    role = params[:membership][:role] || :member
    membership = @team.add_member(user, role: role)

    if membership.persisted?
      redirect_to team_index_path, notice: "#{user.name} added to team"
    else
      redirect_to team_index_path, alert: "Failed to add member"
    end
  end

  def update
    new_role = params[:membership][:role]

    if @membership.user.admin_of?(@team) && new_role != "admin"
      redirect_to team_index_path, alert: "Cannot change the owner's role"
      return
    end

    if @membership.update(role: new_role)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to team_index_path, notice: "Role updated" }
      end
    else
      redirect_to team_index_path, alert: "Failed to update role"
    end
  end

  def destroy
    if @membership.owner?
      redirect_to team_index_path, alert: "Cannot remove the team owner"
      return
    end

    @membership.destroy
    redirect_to team_index_path, notice: "Member removed"
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
    redirect_to team_index_path, alert: "You don't have permission to manage members"
  end

  def membership_params
    params.require(:membership).permit(:email_address)
  end
end
