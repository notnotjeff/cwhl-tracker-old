class AddRegularSeasonBooleanToSeasons < ActiveRecord::Migration[5.1]
  def change
    add_column :seasons, :is_regular_season, :boolean
  end
end
