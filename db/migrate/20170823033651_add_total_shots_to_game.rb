class AddTotalShotsToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :home_shots, :integer
    add_column :games, :visitor_shots, :integer
  end
end
