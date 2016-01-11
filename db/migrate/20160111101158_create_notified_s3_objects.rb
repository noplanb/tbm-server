class CreateNotifiedS3Objects < ActiveRecord::Migration
  def change
    create_table :notified_s3_objects do |t|
      t.string :file_name

      t.timestamps null: false
    end
  end
end
