class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.integer :user_id
      t.integer :receiver_id
      t.attachment :file
      t.integer :length
      t.timestamps
    end
    add_index :videos, :user_id
  end
end
