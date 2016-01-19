class AddIndexOnFileNameToNotifiedS3Object < ActiveRecord::Migration
  def change
    add_index :notified_s3_objects, :file_name
  end
end
