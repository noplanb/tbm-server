class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.integer :creator_id
      t.integer :target_id
      t.string :status
      t.string :connection_key

      t.timestamps
    end
  end
end
