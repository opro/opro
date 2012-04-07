class CreateClientApplications < ActiveRecord::Migration
  def change
    create_table :opro_access_grants do |t|
      t.string  :name
      t.string  :app_id
      t.string  :app_secret
      t.integer :user_id
      t.timestamps
    end
  end
end
