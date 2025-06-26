class AddPreferencesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :preferred_language, :string
    add_column :users, :interface_language, :string
  end
end
