class AddOtStatsToTeamGameStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :team_game_statlines, :ot_goals, :integer
    add_column :team_game_statlines, :ot_goals_against, :integer
    add_column :team_game_statlines, :ot_shots, :integer
    add_column :team_game_statlines, :ot_shots_against, :string
    add_column :team_game_statlines, :ot_periods, :integer
  end
end
