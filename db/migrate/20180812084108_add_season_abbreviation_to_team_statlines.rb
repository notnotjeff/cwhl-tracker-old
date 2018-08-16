class AddSeasonAbbreviationToTeamStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :team_statlines, :season_abbreviation, :string
  end
end
