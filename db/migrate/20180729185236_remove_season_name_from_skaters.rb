class RemoveSeasonNameFromSkaters < ActiveRecord::Migration[5.1]
  def change
    remove_column :skaters, :season_name
  end
end
