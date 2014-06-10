class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :video_id
      t.string :status
      t.integer :user_id
      t.integer :receiver_id
      t.attachment :file
      t.integer :length
      t.timestamps
    end
    add_index :videos, :user_id
  end
end
