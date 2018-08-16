class ChangeScaleSoPercent < ActiveRecord::Migration[5.1]
  def change
  	    change_column :team_statlines, :shootout_percent, :decimal, precision: 5, scale: 3
  end
end
