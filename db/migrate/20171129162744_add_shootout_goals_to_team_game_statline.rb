class AddShootoutGoalsToTeamGameStatline < ActiveRecord::Migration[5.1]
  def change
    add_column :team_game_statlines, :so_goals, :integer
    add_column :team_game_statlines, :so_goals_against, :integer
  end
end
