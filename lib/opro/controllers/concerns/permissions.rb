module Opro::Controllers::Concerns::Permissions
  extend ActiveSupport::Concern

  # By default :write permission is required if included in Opro.request_permissions
  # returns Array
  def global_oauth_required_permissions
     [:write] & Opro.request_permissions
  end

  # returns Array of permissions required for controller action
  def oauth_required_permissions
    (@oauth_required_permissions || global_oauth_required_permissions) - skip_oauth_required_permissions
  end

  def skip_oauth_required_permissions
    @skip_oauth_required_permissions ||= []
  end

  def skip_oauth_required_permission(permission)
    @skip_oauth_required_permissions << permission
    @skip_oauth_required_permissions
  end

  def add_oauth_required_permission(permission)
    @oauth_required_permissions ||= global_oauth_required_permissions
    @oauth_required_permissions << permission
  end

  # Checks to make sure client has given permission
  # permission checks can be extended by creating methods
  # oauth_client_can_:method? so to over-write a default check for
  # :write permission, you would need to define oauth_client_can_write?
  def oauth_client_has_permissions?
    return false unless oauth_access_grant.present?
    permissions_valid_array = []
    oauth_required_permissions.each do |permission|
      permissions_valid_array << oauth_client_has_permission?(permission)
    end

    return true unless permissions_valid_array.include?(false)
    false
  end

  def oauth_client_has_permission?(permission)
    oauth_permission_method = "oauth_client_can_#{permission}?".to_sym
    if respond_to?(oauth_permission_method)
      has_permission = method(oauth_permission_method).call
    else
      has_permission = oauth_access_grant.can?(permission.to_sym)
    end
    has_permission
  end

  # Returns boolean
  # if client has been granted write permissions or request is a 'GET' returns true
  def oauth_client_can_write?
    return false unless oauth_access_grant.present?
    return true if env['REQUEST_METHOD'] == 'GET'
    return true if oauth_access_grant.can?(:write)
    false
  end


  module ClassMethods

    def skip_oauth_permissions(*args)
      options     = args.last.is_a?(Hash) ? callbacks.pop : {}
      permissions = args
      prepend_before_action(options) do
        permissions.each do |permission|
          controller.skip_oauth_required_permission(permission)
        end
      end
    end
    alias :skip_oauth_permission :skip_oauth_permissions

    # pass in array of permissions to be validated, add options to pass to filter
    def require_oauth_permissions(*args)
      options     = args.last.is_a?(Hash) ? args.pop : {}
      permissions = args
      prepend_before_action(options) do
        permissions.each do |permission|
          raise "You must add #{permission.inspect} to the oPRO request_permissions setting in an initializer" unless Opro.request_permissions.include?(permission)
          controller.add_oauth_required_permission(permission)
        end
      end
    end
    alias :require_oauth_permission :require_oauth_permissions
  end

end
