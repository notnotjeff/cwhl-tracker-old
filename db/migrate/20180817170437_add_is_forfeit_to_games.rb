class AddIsForfeitToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :is_forfeit, :boolean
  end
end
