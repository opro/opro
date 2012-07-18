class CreateOproAuthGrants < ActiveRecord::Migration
  def change
    create_table  :opro_auth_grants do |t|
      t.string    :code
      t.string    :access_token
      t.string    :refresh_token
      t.text      :permissions
      t.datetime  :access_token_expires_at
      t.integer   :user_id
      t.integer   :application_id

      t.timestamps
    end

    add_index :opro_auth_grants, :code,          :unique => true
    add_index :opro_auth_grants, :access_token,  :unique => true
    add_index :opro_auth_grants, :refresh_token, :unique => true
  end
end
