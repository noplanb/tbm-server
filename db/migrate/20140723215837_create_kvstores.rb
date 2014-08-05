class CreateKvstores < ActiveRecord::Migration
  def change
    create_table :kvstores do |t|
      t.string :key1
      t.string :key2
      t.string :value

      t.timestamps
    end
    add_index :kvstores, :key1
  end
end
