module ActionDispatch::Routing
  class Mapper
    # Includes mount_opro_oauth method for routes. This method is responsible to
    # generate all needed routes for oauth
    def mount_opro_oauth(options = {})
      skip_routes = options[:except].is_a?(Array) ? options[:except] : [options[:except]]

      match 'oauth/new'          => 'oauth/auth#new',          :as => 'oauth_new'
      match 'oauth/authorize'    => 'oauth/auth#create',       :as => 'oauth_authorize'
      match 'oauth/token'        => 'oauth/token#create',      :as => 'oauth_token'

      resources :oauth_docs,        :controller => 'oauth/docs'       unless skip_routes.include?(:docs)
      resources :oauth_tests,       :controller => 'oauth/tests'      unless skip_routes.include?(:tests)
      resources :oauth_client_apps, :controller => 'oauth/client_app' unless skip_routes.include?(:client_apps)
    end
  end
end
