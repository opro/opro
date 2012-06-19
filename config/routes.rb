# look in lib/opro/rails/routes.rb
  # they get added to a users config/routes.rb when the user runs
  # rails g opro:install
  # this functionality is added in `add_opro_routes` of
  # lib/generators/opro/install_generator.rb
Opro::Engine.routes.draw do
  mount_opro_oauth
end