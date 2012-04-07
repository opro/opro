Rails.application.routes.draw do

  match 'oauth/new'           => 'oauth/auth#new'
  match '/oauth/authorize'    => 'oauth/auth#authorize'
  match '/oauth/access_token' => 'oauth/auth#access_token'

  resources :oauth_client_applications, :controller => 'oauth/client_application'
end