class AddPlayoffsAndRegularSeasonToSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :is_playoffs, :boolean
    add_column :skaters, :is_regular_season, :boolean
  end
end
