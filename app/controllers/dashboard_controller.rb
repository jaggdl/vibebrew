class DashboardController < ApplicationController
  def index
    @rotations = Current.user.rotations.order(created_at: :desc)
    @team_latest = Current.team.coffee_beans.published.where.not(user: Current.user).order(created_at: :desc)
  end
end
