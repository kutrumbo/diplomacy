class AddReferences < ActiveRecord::Migration[6.0]
  def change
    add_reference :user_games, :game, null: false, foreign_key: true
    add_reference :user_games, :user, null: false, foreign_key: true

    add_reference :turns, :game, null: false, foreign_key: true

    add_reference :orders, :user_game, null: false, foreign_key: true
    add_reference :orders, :turn, null: false, foreign_key: true
    add_reference :orders, :position, null: false, foreign_key: true
    add_reference :orders, :from, null: true, foreign_key: { to_table: :areas }
    add_reference :orders, :to, null: true, foreign_key: { to_table: :areas }

    add_reference :coasts, :area, null: false, foreign_key: true

    add_reference :positions, :area, null: false, foreign_key: true
    add_reference :positions, :coast, null: true, foreign_key: true
    add_reference :positions, :user_game, null: false, foreign_key: true

    add_reference :neighbors, :area, null: false, foreign_key: true
    add_reference :neighbors, :neighbor, null: false, polymorphic: true, index: true
  end
end
