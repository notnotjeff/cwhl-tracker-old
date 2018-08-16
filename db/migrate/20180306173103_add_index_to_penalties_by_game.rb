class AddIndexToPenaltiesByGame < ActiveRecord::Migration[5.1]
  def change
    add_index :penalties, :game_id
  end
end
