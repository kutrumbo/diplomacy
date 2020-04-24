class CreateTurns < ActiveRecord::Migration[6.0]
  def change
    create_table :turns do |t|
      t.string :type, null: false
      t.integer :number, null: false

      t.timestamps
    end
  end
end
