class AddIsPlayoffsToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :is_playoffs, :boolean
  end
end
