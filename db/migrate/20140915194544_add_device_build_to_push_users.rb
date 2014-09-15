class AddDeviceBuildToPushUsers < ActiveRecord::Migration
  def change
    add_column :push_users, :device_build, :string
  end
end
