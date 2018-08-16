class AddGameTimeElapsedToPenalties < ActiveRecord::Migration[5.1]
  def change
    add_column :penalties, :game_time_elapsed, :integer
  end
end
