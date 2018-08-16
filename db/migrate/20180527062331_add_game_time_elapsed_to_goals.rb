class AddGameTimeElapsedToGoals < ActiveRecord::Migration[5.1]
  def change
    add_column :goals, :game_time_elapsed, :integer
  end
end
