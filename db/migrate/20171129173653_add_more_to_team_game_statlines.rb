class AddMoreToTeamGameStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :team_game_statlines, :won, :boolean
    add_column :team_game_statlines, :opponent_id, :integer
    add_column :team_game_statlines, :opponent_abbreviation, :string
  end
end
