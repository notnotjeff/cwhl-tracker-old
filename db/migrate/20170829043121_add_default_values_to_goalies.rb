class AddDefaultValuesToGoalies < ActiveRecord::Migration[5.1]
  def change
  	change_column :goalies, :shootout_percent, :decimal, precision: 5, scale: 2, default: 0
  	change_column :goalies, :shots_against_pg, :decimal, precision: 5, scale: 2, default: 0
    change_column :goalies, :goals_against_average, :decimal, precision: 5, scale: 2, default: 0
    change_column :goalies, :save_percentage, :decimal, precision: 5, scale: 2, default: 0
  end
end
