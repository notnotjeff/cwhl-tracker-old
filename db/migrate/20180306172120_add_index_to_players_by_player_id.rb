class AddIndexToPlayersByPlayerId < ActiveRecord::Migration[5.1]
  def change
    add_index :players, :ahl_id
  end
end
