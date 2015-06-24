class SetUsersEmailsTypeToText < ActiveRecord::Migration
  def change
    change_column :users, :emails, :text
  end
end
