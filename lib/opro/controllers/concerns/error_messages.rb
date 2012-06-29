module Opro::Controllers::Concerns::ErrorMessages
  extend ActiveSupport::Concern

  def generate_oauth_error_message!
    msg = ""
    msg << ' - No OAuth Token Provided!'    if oauth_access_token.blank?
    msg << ' - Allow OAuth set to false!'   if allow_oauth? == false
    msg << ' - OAuth user not found!'       if oauth_user.blank?
    msg = generate_oauth_permissions_error_message!(msg)
    msg
  end

  def generate_oauth_permissions_error_message!(msg = '')
    if !oauth_client_has_permissions?
      msg << ' - OAuth client not permitted'
      oauth_required_permissions.each do |permission|
        msg << "- #{permission} permission required;" unless oauth_client_has_permission?(permission)
      end
    end
    msg
  end

end