class AddSeasonIdToPlayerGameStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :player_game_statlines, :season_id, :integer
  end
end
