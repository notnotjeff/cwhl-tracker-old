class AddPlayoffsAndRegularSeasonToGoalies < ActiveRecord::Migration[5.1]
  def change
    add_column :goalies, :is_playoffs, :boolean
    add_column :goalies, :is_regular_season, :boolean
  end
end
