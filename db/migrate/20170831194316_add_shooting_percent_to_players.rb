class AddShootingPercentToPlayers < ActiveRecord::Migration[5.1]
  def change
  	add_column :players, :shooting_percent, :decimal, precision: 6, scale: 3
  end
end
