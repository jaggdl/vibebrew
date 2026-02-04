class TeamController < ApplicationController
  def index
    @team = Current.team
  end
end
