class AddHomeAndVisitorAbbreviationsToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :home_abbreviation, :string
    add_column :games, :visitor_abbreviation, :string
  end
end
