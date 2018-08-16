class AddIndexToAhlGameIdInGames < ActiveRecord::Migration[5.1]
  def change
    add_index :games, :ahl_game_id
  end
end
