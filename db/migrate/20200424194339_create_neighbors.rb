class CreateNeighbors < ActiveRecord::Migration[6.0]
  def change
    create_table :neighbors do |t|

      t.timestamps
    end
  end
end
