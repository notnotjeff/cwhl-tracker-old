class AddOpposingTeamIdToPlayerGameStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :player_game_statlines, :opposing_team_id, :integer
  end
end
