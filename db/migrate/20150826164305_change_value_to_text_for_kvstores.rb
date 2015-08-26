class ChangeValueToTextForKvstores < ActiveRecord::Migration
  def change
    change_column :kvstores, :value, :text
  end
end
