class AddSeasonNameToSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :season_name, :string
  end
end
