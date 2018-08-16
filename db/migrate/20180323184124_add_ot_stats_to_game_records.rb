class AddOtStatsToGameRecords < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :ot_period_home_goals, :integer
    add_column :games, :ot_period_home_shots, :integer
    add_column :games, :ot_period_visitor_goals, :integer
    add_column :games, :ot_period_visitor_shots, :integer
  end
end
