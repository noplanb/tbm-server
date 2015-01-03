class CreateS3Infos < ActiveRecord::Migration
  def change
    create_table :s3_infos do |t|
      t.string :region
      t.string :bucket
      t.string :access_key
      t.string :secret_key

      t.timestamps
    end
  end
end
