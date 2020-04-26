class AddStateToUserGame < ActiveRecord::Migration[6.0]
  def change
    add_column :user_games, :state, :string, null: false
  end
end
