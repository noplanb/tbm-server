class UpgradeUsersEmailColumn < ActiveRecord::Migration
  def change
    rename_column :users, :email, :emails
    change_column :users, :emails, :text
  end
end
