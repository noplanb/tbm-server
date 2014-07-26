class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :filename
      t.attachment :file
      t.integer :length
      t.timestamps
    end
    add_index :videos, :filename
  end
end
