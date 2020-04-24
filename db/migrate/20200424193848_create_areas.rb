class CreateAreas < ActiveRecord::Migration[6.0]
  def change
    create_table :areas do |t|
      t.string :name, null: false
      t.string :type, null: false
      t.boolean :supply_center, null: false

      t.timestamps
    end
  end
end
