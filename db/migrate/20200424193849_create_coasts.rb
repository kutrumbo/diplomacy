class CreateCoasts < ActiveRecord::Migration[6.0]
  def change
    create_table :coasts do |t|
      t.string :direction, null: false

      t.timestamps
    end
  end
end
