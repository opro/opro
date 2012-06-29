class Opro::Oauth::AuthGrant < ActiveRecord::Base

  self.table_name = :opro_auth_grants

  belongs_to :user
  belongs_to :client_application, :class_name => "Oauth::ClientApp"
  belongs_to :application,        :class_name => "Oauth::ClientApp"

  validates :application_id, :uniqueness => {:scope => :user_id, :message => "Application is already authed for this user"}, :presence => true

  before_create :generate_tokens!, :generate_expires_at!

  alias_attribute :token, :access_token

  serialize :permissions, Hash

  def can?(value)
    permissions[value.to_s]
  end

  def expired?
    return false unless ::Opro.require_refresh_within.present?
    return expires_in < 0
  end

  def not_expired?
    !expired?
  end

  def expires_in
    return false unless access_token_expires_at.present?
    time = access_token_expires_at - Time.now
    time.to_i
  end

  def self.find_for_token(token)
    self.where(:access_token => token).includes(:user, :client_application).first
  end

  def self.find_user_for_token(token)
    find_app_for_token.try(:user)
  end

  def self.auth_with_code!(code, application_id)
    auth_grant = self.where("code = ? AND application_id = ?", code, application_id).first
  end

  def self.auth_with_user!(user, applicaiton_id, permissions = ::Opro.request_permissions)
    return false unless user
    permissions_hash =   permissions.each_with_object({}) {|element, hash| hash[element] = true }
    auth_grant  =   self.where(:user_id  => user.id, :application_id => applicaiton_id).first
    auth_grant  ||= self.create(:user_id => user.id, :application_id => applicaiton_id)
    auth_grant.update_attributes(:permissions => permissions_hash)
    auth_grant
  end

  def self.refresh_tokens!(refresh_token, application_id)
    auth_grant = self.where("refresh_token = ? AND application_id = ?", refresh_token, application_id).first
    if auth_grant.present?
      auth_grant.generate_tokens!
      auth_grant.generate_expires_at!
      auth_grant.save!
    end
    auth_grant
  end

  def generate_expires_at!
    if ::Opro.require_refresh_within.present?
      self.access_token_expires_at = Time.now + ::Opro.require_refresh_within
    else
      self.access_token_expires_at = nil
    end
    true
  end

  def generate_tokens!
    self.code, self.access_token, self.refresh_token = SecureRandom.hex(16), SecureRandom.hex(16), SecureRandom.hex(16)
  end

  def redirect_uri_for(redirect_uri)
    if redirect_uri =~ /\?/
      redirect_uri + "&code=#{code}&response_type=code"
    else
      redirect_uri + "?code=#{code}&response_type=code"
    end
  end
end