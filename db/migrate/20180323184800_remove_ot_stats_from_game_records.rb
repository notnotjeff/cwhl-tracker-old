class RemoveOtStatsFromGameRecords < ActiveRecord::Migration[5.1]
  def change
    remove_column :games, :ot_period_home_goals
    remove_column :games, :ot_period_home_shots
    remove_column :games, :ot_period_visitor_goals
    remove_column :games, :ot_period_visitor_shots
  end
end
