class AddTotalShotsToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :home_total_shots, :integer
    add_column :games, :visitor_total_shots, :integer
  end
end
