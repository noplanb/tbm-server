class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
      t.string :cred_type
      t.text :cred

      t.timestamps
    end
    add_index :credentials, :cred_type
  end
end
