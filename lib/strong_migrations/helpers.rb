module StrongMigrations
  module Helpers
    def self.ar_version
      ActiveRecord::VERSION::STRING.to_f
    end

    def self.supports_multiple_dbs?
      ar_version >= 6.0
    end
  end
end
