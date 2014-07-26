class CreateKvstores < ActiveRecord::Migration
  def change
    create_table :kvstores do |t|
      t.string :key
      t.string :value

      t.timestamps
    end
    add_index :kvstores, :key
  end
end
