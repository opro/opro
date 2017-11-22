class Opro::Oauth::AuthGrant < ActiveRecord::Base

  self.table_name = :opro_auth_grants

  belongs_to :user
  belongs_to :client_application, :class_name => "Opro::Oauth::ClientApp", :foreign_key => "application_id"
  belongs_to :application,        :class_name => "Opro::Oauth::ClientApp", :foreign_key => "application_id"
  belongs_to :client_app,         :class_name => "Opro::Oauth::ClientApp", :foreign_key => "application_id"


  validates :application_id, :uniqueness => {:scope => :user_id, :message => "Application is already authorized for this user"}, :presence => true
  validates :code,           :uniqueness => true
  validates :access_token,   :uniqueness => true

  before_create :refresh

  alias_attribute :token, :access_token

  serialize :permissions, Hash

  # attr_accessible :code, :access_token, :refresh_token, :access_token_expires_at, :permissions, :user_id, :user, :application_id, :application

  def can?(value)
    HashWithIndifferentAccess.new(permissions)[value]
  end

  def expired?
    return false unless ::Opro.require_refresh_within.present?
    return expires_in && expires_in < 0
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

  def self.find_by_code_app(code, app)
    app_id = app.is_a?(Integer) ? app : app.id
    auth_grant = self.where("code = ? AND application_id = ?", code, app_id).first
  end

  # turns array of permissions into a hash
  # [:write, :read] => {write: true, read: true}
  def default_permissions
    ::Opro.request_permissions.each_with_object({}) {|element, hash| hash[element] = true }
  end

  def self.find_or_create_by_user_app(user, app)
    app_id = app.is_a?(Integer) ? app : app.id
    auth_grant  =   self.where(:user_id  => user.id, :application_id => app_id).first
    auth_grant  ||= begin
      auth_grant                = self.new
      auth_grant.user_id        = user.id
      auth_grant.application_id = app_id
      auth_grant.save
      auth_grant
    end
  end

  def update_permissions(permissions = default_permissions)
    permissions = permissions.to_h
    self.permissions = permissions and save if self.permissions != permissions
  end

  def self.find_by_refresh_app(refresh_token, application_id)
    self.where("refresh_token = ? AND application_id = ?", refresh_token, application_id).first
  end

  # generates tokens, expires_at and saves
  def refresh!
    refresh
    save!
  end

  # generates tokens, expires_at
  def refresh
    generate_tokens!
    generate_expires_at!
    self
  end

  # used to guarantee that we are generating unique codes, access_tokens and refresh_tokens
  def unique_token_for(field, secure_token  = SecureRandom.hex(16))
    raise "bad field" unless self.respond_to?(field)
    auth_grant = self.class.where(field => secure_token).first
    return secure_token if auth_grant.blank?
    unique_token_for(field)
  end

  def redirect_uri_for(redirect_uri, state = nil)
    if redirect_uri =~ /\?/
      redirect_uri << "&code=#{code}&response_type=code"
    else
      redirect_uri << "?code=#{code}&response_type=code"
    end
    redirect_uri << "&state=#{state}" if state.present?
    redirect_uri
  end

  private
  # use refresh instead
  def generate_expires_at!
    if ::Opro.require_refresh_within.present?
      self.access_token_expires_at = Time.now + ::Opro.require_refresh_within
    else
      self.access_token_expires_at = nil
    end
    true
  end

  # use refresh instead
  def generate_tokens!
    self.code          = unique_token_for(:code)
    self.access_token  = unique_token_for(:access_token)
    self.refresh_token = unique_token_for(:refresh_token)
  end
end
