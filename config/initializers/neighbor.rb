# frozen_string_literal: true

begin
  Neighbor::SQLite.initialize!
rescue LoadError => e
  Rails.logger.warn "Could not initialize sqlite-vec: #{e.message}" if Rails.respond_to?(:logger) && Rails.logger
end
