class RemovePlayoffRegularSeasonFromGoaliesAndSkaters < ActiveRecord::Migration[5.1]
  def change
    remove_column :goalies, :is_playoffs
    remove_column :goalies, :is_regular_season
    remove_column :skaters, :is_playoffs
    remove_column :skaters, :is_regular_season
  end
end
