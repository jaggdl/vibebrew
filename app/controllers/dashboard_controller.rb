class DashboardController < ApplicationController
  def index
    @rotations = Current.user.rotations.order(created_at: :desc)
    @latest_beans = Current.user.coffee_beans.where.not(id: @rotations.select(:id)).order(created_at: :desc).limit(3)
    @team_latest = Current.team.coffee_beans.published.where.not(user: Current.user).order(created_at: :desc)
  end
end
