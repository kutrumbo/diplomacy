class AddPowerToPosition < ActiveRecord::Migration[6.0]
  def change
    add_column :positions, :power, :string, null: true
    add_column :positions, :dislodged, :boolean, null: false
    add_reference :positions, :turn, null: false, foreign_key: true

    add_column :orders, :confirmed, :boolean, null: false
    remove_column :user_games, :state, :string, null: false
  end
end
