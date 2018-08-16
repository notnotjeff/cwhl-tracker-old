class AddPlayerSeasonTeamIndexToOnIceSkaters < ActiveRecord::Migration[5.1]
  def change
    add_index :on_ice_skaters, [:player_id, :season_id, :team_id]
  end
end
