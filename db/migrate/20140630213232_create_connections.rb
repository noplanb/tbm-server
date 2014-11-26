class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.integer :creator_id
      t.integer :target_id
      t.string :status
      t.string :connection_key

      t.timestamps
    end
    add_index :connections, :creator_id
    add_index :connections, :target_id
    add_index :connections, :connection_key
  end
end
