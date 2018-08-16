class AddGameNameToPlayerGameStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :player_game_statlines, :game_name, :string
  end
end
