class AddPsPercentToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :ps_percent, :decimal, precision: 5, scale: 2
  end
end
