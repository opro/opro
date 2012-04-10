class ApplicationController < ActionController::Base
  protect_from_forgery

  allow_oauth!

end
