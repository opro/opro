require 'securerandom'

module Opro
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates an oPRO initializer"
      class_option :orm

      def copy_initializer
        template "opro.rb", "config/initializers/opro.rb"
      end

      def run_other_generators
        generate "active_record:opro"
      end

      def add_opro_routes
        opro_routes = "mount_opro_oauth"
        route opro_routes
      end
    end
  end
end

