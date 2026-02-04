module Saas
  class TeamsController < ApplicationController
    skip_before_action :require_team, only: [ :index, :new, :create ]
    before_action :set_team, only: [ :show, :edit, :update, :destroy ]
    before_action :require_owner, only: [ :edit, :update, :destroy ]

    def index
      @teams = Current.user.teams
    end

    def show
      @memberships = @team.memberships.includes(:user)
      @usage = @team.usage_stats
    end

    def new
      @team = Saas::Team.new
    end

    def create
      @team = Saas::Team.new(team_params)

      if @team.save
        # Add current user as owner
        @team.add_member(Current.user, role: :owner)

        # Create free subscription
        Saas::Subscription.create!(
          team: @team,
          plan_name: "free",
          status: :active
        )

        redirect_to saas.team_path(@team), notice: "Team created successfully"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @team.update(team_params)
        redirect_to saas.team_path(@team), notice: "Team updated successfully"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @team.destroy
      redirect_to saas.teams_path, notice: "Team deleted"
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
end
