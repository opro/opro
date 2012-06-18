require 'rails/generators/migration'


module ActiveRecord
  module Generators
    class OproGenerator < ::Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)

      desc "add the migrations needed for opro oauth"

      def self.next_migration_number(path)
        unless @prev_migration_nr
          @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
        else
          @prev_migration_nr += 1
        end
        @prev_migration_nr.to_s
      end


      def copy_migrations
        migration_template "access_grants.rb",       "db/migrate/create_opro_access_grants.rb"
        migration_template "client_applications.rb", "db/migrate/create_opro_client_applications.rb"
      end
    end
  end
end
