class AddSeasonAbbreviationToSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :season_abbreviation, :string
  end
end
