class TeamsController < ApplicationController
  before_action :set_team, only: [ :show, :edit, :update, :destroy ]

  def require_team
    return if [ "index", "new", "create" ].include?(action_name)
    super
  end

  def index
    @teams = Current.user.teams
  end

  def show
    @memberships = @team.memberships.includes(:user)
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)

    if @team.save
      @team.add_member(Current.user, role: :owner)
      redirect_to team_path(@team), notice: "Team created successfully"
    else
      render :new, status: :unprocessable_entity
    end
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

  def destroy
    @team.destroy
    redirect_to teams_path, notice: "Team deleted"
  end

  def switch
    team = Current.user.teams.find(params[:id])
    session[:current_team_id] = team.id
    redirect_to root_path, notice: "Switched to #{team.name}"
  end

  private

  def set_team
    @team = Current.user.teams.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
