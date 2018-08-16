class RemoveA1AndA2FromGoalieGameStatlines < ActiveRecord::Migration[5.1]
  def change
  	remove_column :goalie_game_statlines, :a1
  	remove_column :goalie_game_statlines, :a2
  end
end
