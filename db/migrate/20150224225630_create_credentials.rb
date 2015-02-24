class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
      t.string :type
      t.string :cred

      t.timestamps
    end
    add_index :credentials, :type
  end
end
