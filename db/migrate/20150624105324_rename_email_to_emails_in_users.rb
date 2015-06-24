class RenameEmailToEmailsInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :email, :emails
  end
end
