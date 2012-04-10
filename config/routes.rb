Rails.application.routes.draw do

  match 'oauth/new'           => 'oauth/auth#new',          :as => 'oauth_new'
  match '/oauth/authorize'    => 'oauth/auth#authorize',    :as => 'oauth_authorize'
  match '/oauth/access_token' => 'oauth/auth#access_token', :as => 'oauth_token'

  resources :oauth_docs,                :controller => 'oauth/docs'
  resources :oauth_tests,               :controller => 'oauth/tests'
  resources :oauth_client_applications, :controller => 'oauth/client_application'
end