class AddCoastalToBorders < ActiveRecord::Migration[6.0]
  def change
    add_column :borders, :coastal, :boolean, null: false, default: false
  end
end
