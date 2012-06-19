require 'opro/rails/routes'

module Opro
  class Engine < Rails::Engine

    initializer "opro.include_helpers" do
      Opro.include_helpers(Opro::Controllers)
    end
  end
end
