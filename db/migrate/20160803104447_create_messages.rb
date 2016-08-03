class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :sender
      t.string :receiver
      t.integer :message_id
      t.string :type
      t.text :transcription

      t.timestamps null: false
    end
  end
end
