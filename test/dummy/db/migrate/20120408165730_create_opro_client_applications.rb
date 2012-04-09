class CreateOproClientApplications < ActiveRecord::Migration
  def change
    create_table :opro_client_applications do |t|
      t.string  :name
      t.string  :app_id
      t.string  :app_secret
      t.integer :user_id
      t.timestamps
    end
  end
end
