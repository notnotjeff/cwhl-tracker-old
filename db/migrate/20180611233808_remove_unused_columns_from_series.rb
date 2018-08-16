class RemoveUnusedColumnsFromSeries < ActiveRecord::Migration[5.1]
  def change
    remove_column :series, :home_team_id, :integer
    remove_column :series, :visiting_team_id, :integer
    remove_column :series, :winning_team_id, :integer
    remove_column :series, :losing_team_id, :integer
    remove_column :series, :home_team_wins, :integer
    remove_column :series, :visiting_team_wins, :integer
    remove_column :series, :wins_at_home, :integer
    remove_column :series, :wins_on_road, :integer
    remove_column :series, :home_goals_for, :integer
    remove_column :series, :home_goals_against, :integer
    remove_column :series, :home_goals_for_percent, :decimal
    remove_column :series, :visitor_goals_for, :integer
    remove_column :series, :visitor_goals_against, :integer
    remove_column :series, :visitor_goals_for_percent, :decimal
    remove_column :series, :home_shots_for, :integer
    remove_column :series, :home_shots_against, :integer
    remove_column :series, :home_shots_for_percent, :decimal
    remove_column :series, :visitor_shots_for, :integer
    remove_column :series, :visitor_shots_against, :integer
    remove_column :series, :visitor_shots_for_percent, :decimal
    remove_column :series, :home_save_percent, :decimal
    remove_column :series, :visitor_save_percent, :decimal
    remove_column :series, :home_shooting_percent, :decimal
    remove_column :series, :visitor_shooting_percent, :decimal
  end
end
