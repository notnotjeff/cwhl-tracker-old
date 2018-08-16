class AddIsHomeGameToPlayerGameStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :player_game_statlines, :is_home_game, :boolean
  end
end
