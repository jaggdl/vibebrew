module Public
  class BaseController < ApplicationController
    layout "public"
    allow_unauthenticated_access

    private

    def require_published(record)
      raise ActiveRecord::RecordNotFound unless record&.published?
    end
  end
end
