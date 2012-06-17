Rails.application.routes.draw do

  match 'oauth/new'           => 'oauth/auth#new',          :as => 'oauth_new'
  match '/oauth/authorize'    => 'oauth/auth#create',       :as => 'oauth_authorize'
  match '/oauth/token'        => 'oauth/token#create',      :as => 'oauth_token'

  resources :oauth_docs,        :controller => 'oauth/docs'
  resources :oauth_tests,       :controller => 'oauth/tests'
  resources :oauth_client_apps, :controller => 'oauth/client_app'
end