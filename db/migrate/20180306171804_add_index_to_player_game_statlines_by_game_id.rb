class AddIndexToPlayerGameStatlinesByGameId < ActiveRecord::Migration[5.1]
  def change
    add_index :player_game_statlines, :game_id
  end
end
