class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :sender
      t.string :receiver
      t.string :message_id
      t.string :message_type
      t.text :transcription

      t.timestamps null: false
    end
  end
end
