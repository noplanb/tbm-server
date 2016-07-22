class AddDeviceInfoToUser < ActiveRecord::Migration
  def change
    add_column :users, :device_info, :string
  end
end
