class CreatePushUsers < ActiveRecord::Migration
  def change
    create_table :push_users do |t|
      t.string :mkey
      t.string :push_token
      t.string :device_platform

      t.timestamps
    end
    add_index :push_users, :mkey
  end
end
