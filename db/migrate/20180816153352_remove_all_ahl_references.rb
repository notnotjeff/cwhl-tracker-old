class RemoveAllAhlReferences < ActiveRecord::Migration[5.1]
  def change
    rename_column :divisions, :ahl_division_id, :cwhl_division_id

    rename_column :games, :ahl_game_id, :cwhl_game_id

    rename_column :overtimes, :ahl_game_id, :cwhl_game_id

    rename_column :players, :ahl_id, :cwhl_id

    rename_column :seasons, :ahl_id, :cwhl_id
  end
end
