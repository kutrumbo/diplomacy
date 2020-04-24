class AddPowerToArea < ActiveRecord::Migration[6.0]
  def change
    add_column :areas, :power, :string, null: true
  end
end
