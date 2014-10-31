class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :mobile_number
      t.string :email
      t.string :user_name
      t.string :device_platform
      t.string :auth
      t.string :mkey
      t.string :verification_code
      t.datetime :verification_date_time
      t.string :status

      t.timestamps
    end
  end
end
