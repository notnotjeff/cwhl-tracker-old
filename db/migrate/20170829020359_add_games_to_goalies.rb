class AddGamesToGoalies < ActiveRecord::Migration[5.1]
  def change
    add_column :goalies, :games_played, :integer
    add_column :goalies, :penalty_shot_goals_against, :integer
    add_column :goalies, :shootout_attempts, :integer
    add_column :goalies, :shootout_goals_against, :integer
    add_column :goalies, :shootout_percent, :decimal
  end
end
