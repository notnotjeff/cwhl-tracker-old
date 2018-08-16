class AddIndexToSkatersPlayerSeasonTeam < ActiveRecord::Migration[5.1]
  def change
    add_index :skaters, [:player_id, :season_id, :team_id]
  end
end
