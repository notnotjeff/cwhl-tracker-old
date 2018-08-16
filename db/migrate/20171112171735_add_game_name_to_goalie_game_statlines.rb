class AddGameNameToGoalieGameStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :goalie_game_statlines, :game_name, :string
  end
end
