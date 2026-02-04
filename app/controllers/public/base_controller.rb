module Public
  class BaseController < ApplicationController
    layout "public"
    allow_unauthenticated_access

    skip_before_action :require_team

    private

    def require_published(record)
      raise ActiveRecord::RecordNotFound unless record&.published?
    end
  end
end
