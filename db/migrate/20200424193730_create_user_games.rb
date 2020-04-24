class CreateUserGames < ActiveRecord::Migration[6.0]
  def change
    create_table :user_games do |t|
      t.string :power, null: false

      t.timestamps
    end
  end
end
