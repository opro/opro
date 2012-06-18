class CreateOproClientApps < ActiveRecord::Migration
  def change
    create_table :opro_client_apps do |t|
      t.string  :name
      t.string  :app_id
      t.string  :app_secret
      t.text    :permissions
      t.integer :user_id
      t.timestamps
    end
  end
end
