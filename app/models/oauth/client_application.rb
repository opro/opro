class Oauth::ClientApplication < ActiveRecord::Base

  set_table_name :opro_client_applications

  belongs_to :user
  validates  :app_id, :uniqueness => true
  validates  :name,   :uniqueness => true

  alias_attribute :client_id, :app_id

  def self.authenticate(app_id, app_secret)
    where(["app_id = ? AND app_secret = ?", app_id, app_secret]).first
  end

  def self.create_with_user_and_name(user, name)
    create(:user => user, :name => name, :app_id => generate_id, :app_secret => SecureRandom.hex(16))
  end

  def self.generate_id
    app_id     = SecureRandom.hex(16)
    client_app = where(:app_id => app_id)
    if client_app.present?
      generate_id
    else
      return app_id
    end
  end
end