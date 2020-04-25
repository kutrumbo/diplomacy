class AddUnitsToAreaAndFixPositionType < ActiveRecord::Migration[6.0]
  def change
    add_column :areas, :unit, :string
    add_column :areas, :coast, :string
    change_column_null :positions, :type, :true
  end
end
