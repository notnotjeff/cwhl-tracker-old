class AddCurrentSeasonToSeasons < ActiveRecord::Migration[5.1]
  def change
    add_column :seasons, :current_season, :boolean
  end
end
