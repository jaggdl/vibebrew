module Saas
  class ApplicationController < ::ApplicationController
    before_action :require_team

    private

    def require_team
      return if Current.team.present?
      redirect_to root_path, alert: "Please select a team"
    end

    def require_owner
      return if Current.can_manage_settings?
      redirect_to root_path, alert: "You don't have permission to access this page"
    end

    def require_billing_access
      return if Current.can_manage_billing?
      redirect_to root_path, alert: "You don't have permission to access billing"
    end
  end
end
