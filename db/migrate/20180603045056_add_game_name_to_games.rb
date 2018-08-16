class AddGameNameToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :game_name, :string
  end
end
