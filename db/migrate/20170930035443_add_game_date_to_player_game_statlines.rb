class AddGameDateToPlayerGameStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :player_game_statlines, :game_date, :datetime
  end
end
