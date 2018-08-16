class AddGoalsCountToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :goals_count, :integer
  end
end
