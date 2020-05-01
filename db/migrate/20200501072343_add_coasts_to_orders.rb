class AddCoastsToOrders < ActiveRecord::Migration[6.0]
  def change
    add_reference :orders, :from_coast, null: true, foreign_key: { to_table: :coasts }
    add_reference :orders, :to_coast, null: true, foreign_key: { to_table: :coasts }
  end
end
