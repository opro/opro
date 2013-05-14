class Opro::Oauth::ClientApp < ActiveRecord::Base
  self.table_name = :opro_client_apps

  belongs_to :user
  validates  :app_id, :uniqueness => true
  validates  :name,   :uniqueness => true

  alias_attribute :client_id, :app_id

  alias_attribute :client_secret, :app_secret
  alias_attribute :secret,        :app_secret

  serialize :permissions, Hash

  # attr_accessible :user, :name, :app_id, :client_secret, :app_secret, :secret

  def self.find_by_client_id(client_id)
    where(app_id: client_id).first
  end

  def self.authenticate(app_id, app_secret)
    where(["app_id = ? AND app_secret = ?", app_id, app_secret]).first
  end

  def self.create_with_user_and_name(user, name)
    client_app            = self.new
    client_app.user       = user
    client_app.name       = name
    client_app.app_id     = generate_unique_app_id
    client_app.app_secret = SecureRandom.hex(16)
    client_app.save
    client_app
  end

  def self.generate_unique_app_id(app_id = SecureRandom.hex(16))
    client_app = where(:app_id => app_id)
    return app_id if client_app.blank?
    generate_unique_app_id
  end
end