class TeamsController < ApplicationController
  before_action :set_team, only: [ :show, :edit, :update, :regenerate_invite ]

  skip_before_action :require_team, only: [ :index ]

  def index
    @teams = Current.user.teams
  end

  def show
    @memberships = @team.memberships.includes(:user)
  end

  def edit
  end

  def update
    if @team.update(team_params)
      redirect_to team_path(@team), notice: "Team updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def switch
    team = Current.user.teams.find(params[:id])
    session[:current_team_id] = team.id
    redirect_to root_path, notice: "Switched to #{team.name}"
  end

  def regenerate_invite
    @team.regenerate_invite_code!
    redirect_to team_path(@team), notice: "Invite link regenerated"
  end

  private

  def set_team
    @team = Current.user.teams.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
