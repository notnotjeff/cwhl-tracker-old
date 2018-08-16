class AddPointsToGoalieGameStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :goalie_game_statlines, :goals, :integer
    add_column :goalie_game_statlines, :a1, :integer
    add_column :goalie_game_statlines, :a2, :integer
    add_column :goalie_game_statlines, :points, :integer
  end
end
