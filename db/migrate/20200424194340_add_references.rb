class AddReferences < ActiveRecord::Migration[6.0]
  def change
    add_reference :user_games, :game, foreign_key: true
    add_reference :user_games, :user, foreign_key: true

    add_reference :turns, :game, foreign_key: true

    add_reference :orders, :user_game, foreign_key: true
    add_reference :orders, :turn, foreign_key: true
    add_reference :orders, :position, foreign_key: true
    add_reference :orders, :from, null: true, foreign_key: { to_table: :areas }
    add_reference :orders, :to, null: true, foreign_key: { to_table: :areas }

    add_reference :areas, :coast, foreign_key: true

    add_reference :positions, :area, foreign_key: true
    add_reference :positions, :coast, null: true, foreign_key: true
    add_reference :positions, :user_game, foreign_key: true

    add_reference :neighbors, :area, foreign_key: true
    add_reference :neighbors, :neighbor, polymorphic: true, index: true
  end
end
