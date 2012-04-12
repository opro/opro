class Oauth::AccessGrant < ActiveRecord::Base

  self.table_name = :opro_access_grants

  belongs_to :user
  belongs_to :client_application, :class_name => "Oauth::ClientApplication"
  belongs_to :application,        :class_name => "Oauth::ClientApplication"

  validates :application_id, :uniqueness => {:scope => :user_id, :message => "Applicaiton is already authed for this user"}, :presence => true

  before_create :generate_tokens

  alias_attribute :token, :access_token

  def self.prune!
    # UPDATEME
    # delete_all(["created_at < ?", 3.days.ago])
  end

  def self.find_user_for_token(token)
    self.where(:access_token => token).first.try(:user)
  end

  def self.authenticate(code, application_id)
    self.where("code = ? AND application_id = ?", code, application_id).first
  end

  def generate_tokens
    self.code, self.access_token, self.refresh_token = SecureRandom.hex(16), SecureRandom.hex(16), SecureRandom.hex(16)
  end

  def redirect_uri_for(redirect_uri)
    if redirect_uri =~ /\?/
      redirect_uri + "&code=#{code}&response_type=code"
    else
      redirect_uri + "?code=#{code}&response_type=code"
    end
  end

  def start_expiry_period!
    # UPDATEME
    # self.update_attribute(:access_token_expires_at, 2.days.from_now)
  end
end