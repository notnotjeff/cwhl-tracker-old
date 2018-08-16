class AddGameIdAndSeasonIdToReferees < ActiveRecord::Migration[5.1]
  def change
    add_column :referees, :game_id, :integer
    add_column :referees, :season_id, :integer
  end
end
