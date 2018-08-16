class AddSavePercentageToGoalieGameStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :goalie_game_statlines, :save_percent, :decimal, precision: 6, scale: 3, default: "0.0"
  end
end
