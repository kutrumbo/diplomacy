class CreateResolutions < ActiveRecord::Migration[6.0]
  def change
    create_table :resolutions do |t|
      t.string :status, null: false

      t.timestamps
    end
    add_reference :resolutions, :order, null: true, foreign_key: true
  end
end
