module SetsCurrentTeam
  extend ActiveSupport::Concern

  included do
    before_action :set_current_team
    before_action :require_team
  end

  private

  def set_current_team
    return unless Current.user

    # Get team from session or default to first team
    team_id = session[:current_team_id]

    if team_id.present?
      Current.team = Current.user.teams.find_by(id: team_id)
    end

    # Fall back to first team if session team not found
    Current.team ||= Current.user.teams.first

    # Set membership for current team
    if Current.team
      Current.membership = Membership.find_by(user: Current.user, team: Current.team)
    end
  end

  def require_team
    return if Current.team.present?

    if Current.user.teams.empty?
      redirect_to new_team_path, notice: "Please create a team to get started"
    else
      redirect_to teams_path, notice: "Please select a team"
    end
  end
end
