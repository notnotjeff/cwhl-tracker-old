class AddGameDateToOnIceSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :on_ice_skaters, :game_date, :datetime
  end
end
