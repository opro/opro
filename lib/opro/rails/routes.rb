module ActionDispatch::Routing
  class Mapper
    # Includes mount_opro_oauth method for routes. This method is responsible to
    # generate all needed routes for oauth
    def mount_opro_oauth(options = {})
      skip_routes = options[:except].is_a?(Array) ? options[:except] : [options[:except]]
      controllers = options[:controllers] || {}

      oauth_new_controller = controllers[:oauth_new] || 'opro/oauth/auth'
      get  'oauth/new'          => "#{oauth_new_controller}#new",  :as => 'oauth_new'
      post 'oauth/authorize'    => 'opro/oauth/auth#create',       :as => 'oauth_authorize'
      post 'oauth/token'        => 'opro/oauth/token#create',      :as => 'oauth_token'

      unless skip_routes.include?(:client_apps)
        oauth_client_apps = controllers[:oauth_client_apps] ||'opro/oauth/client_app'
        resources :oauth_client_apps, :controller => oauth_client_apps
      end
      unless skip_routes.include?(:docs)
        oauth_docs = controllers[:oauth_docs] ||'opro/oauth/docs'
        resources :oauth_docs,        :controller => oauth_docs, :only => [:index, :show]
      end
      unless skip_routes.include?(:tests)
        oauth_tests = controllers[:oauth_tests] ||'opro/oauth/tests'
        resources :oauth_tests,       :controller => oauth_tests, :only => [:index, :show, :create, :destroy]
      end
    end
  end
end
