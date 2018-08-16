class AddTeamAbbreviationToSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :team_abbreviation, :string
  end
end
