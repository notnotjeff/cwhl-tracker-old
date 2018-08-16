class AddSeasonAbbreviationToGoalies < ActiveRecord::Migration[5.1]
  def change
    add_column :goalies, :season_abbreviation, :string
  end
end
