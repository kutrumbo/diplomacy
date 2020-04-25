class AddPasswordToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :email, :string
    add_column :users, :password_digest, :string
    add_index :users, :email, unique: true
  end
end
