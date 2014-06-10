class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name 
      t.string :last_name
      t.string :mobile_number
      t.string :push_token
      t.string :device_platform
      t.timestamps
    end
  end
end
