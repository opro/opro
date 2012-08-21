module ActionDispatch::Routing
  class Mapper
    # Includes mount_opro_oauth method for routes. This method is responsible to
    # generate all needed routes for oauth
    def mount_opro_oauth(options = {})
      skip_routes = options[:except].is_a?(Array) ? options[:except] : [options[:except]]
      controllers = options[:controllers] || {}

      match 'oauth/new'          => 'opro/oauth/auth#new',          :as => 'oauth_new'
      match 'oauth/authorize'    => 'opro/oauth/auth#create',       :as => 'oauth_authorize'
      match 'oauth/token'        => 'opro/oauth/token#create',      :as => 'oauth_token'

      resources :oauth_docs,        :controller => controllers[:oauth_docs]       ||'opro/oauth/docs',       :only => [:index, :show]                    unless skip_routes.include?(:docs)
      resources :oauth_tests,       :controller => controllers[:oauth_tests]      ||'opro/oauth/tests',      :only => [:index, :show, :create, :destroy] unless skip_routes.include?(:tests)
      resources :oauth_client_apps, :controller => controllers[:oauth_client_apps]||'opro/oauth/client_app', :only => [:new, :index, :create]            unless skip_routes.include?(:client_apps)
    end
  end
end

