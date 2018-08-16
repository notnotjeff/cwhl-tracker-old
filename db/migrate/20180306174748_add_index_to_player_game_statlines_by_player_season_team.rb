class AddIndexToPlayerGameStatlinesByPlayerSeasonTeam < ActiveRecord::Migration[5.1]
  def change
    add_index :player_game_statlines, [:player_id, :season_id, :team_id], :name => 'index_on_pgs_player_season_team'
  end
end
