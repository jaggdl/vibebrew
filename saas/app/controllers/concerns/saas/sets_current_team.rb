module Saas
  module SetsCurrentTeam
    extend ActiveSupport::Concern

    included do
      before_action :set_current_team, if: -> { VibeBrew.saas? }
      helper_method :current_team, :current_membership, :user_teams
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
        Current.membership = Saas::Membership.find_by(user: Current.user, team: Current.team)
      end
    end

    def current_team
      Current.team if VibeBrew.saas?
    end

    def current_membership
      Current.membership if VibeBrew.saas?
    end

    def user_teams
      return [] unless VibeBrew.saas? && Current.user
      Current.user.teams
    end

    def require_team
      return unless VibeBrew.saas?
      return if Current.team.present?

      if Current.user.teams.empty?
        redirect_to saas.new_team_path, notice: "Please create a team to get started"
      else
        redirect_to saas.teams_path, notice: "Please select a team"
      end
    end
  end
end
