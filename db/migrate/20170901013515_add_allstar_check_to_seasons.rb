class AddAllstarCheckToSeasons < ActiveRecord::Migration[5.1]
  def change
    add_column :seasons, :is_allstar_game, :boolean
  end
end
