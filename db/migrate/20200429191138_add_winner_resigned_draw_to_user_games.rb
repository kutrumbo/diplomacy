class AddWinnerResignedDrawToUserGames < ActiveRecord::Migration[6.0]
  def change
    add_column :user_games, :winner, :boolean, null: false, default: false
    add_column :user_games, :resigned, :boolean, null: false, default: false
    add_column :user_games, :draw, :boolean, null: false, default: false
  end
end
