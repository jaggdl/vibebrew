module Public
  class BaseController < ApplicationController
    allow_unauthenticated_access

    private

    def require_published(record)
      raise ActiveRecord::RecordNotFound unless record&.published?
    end
  end
end
