class AddUnforfeitedGamesPlayedToTeamStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :team_statlines, :unforfeited_games_played, :integer
  end
end
