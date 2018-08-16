class AddIndexToGoalieGameStatlinesByGameId < ActiveRecord::Migration[5.1]
  def change
    add_index :goalie_game_statlines, :game_id
  end
end
