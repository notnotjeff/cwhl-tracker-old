class AddFullNameToSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :full_name, :string
  end
end
