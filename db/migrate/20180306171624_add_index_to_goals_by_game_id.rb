class AddIndexToGoalsByGameId < ActiveRecord::Migration[5.1]
  def change
    add_index :goals, :game_id
  end
end
