class AddAvatarToUser < ActiveRecord::Migration
  def change
    add_column :users, :avatar_timestamp, :integer
    add_column :users, :avatar_use_as_thumbnail, :string
  end
end
