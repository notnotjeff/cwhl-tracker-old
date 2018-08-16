class AddAssistsToGoalieGameStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :goalie_game_statlines, :assists, :integer
  end
end
