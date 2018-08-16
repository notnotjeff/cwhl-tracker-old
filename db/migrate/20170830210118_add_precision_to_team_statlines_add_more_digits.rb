class AddPrecisionToTeamStatlinesAddMoreDigits < ActiveRecord::Migration[5.1]
  def change
  	change_column :team_statlines, :shots_pg, :decimal, precision: 6, scale: 3
    change_column :team_statlines, :shots_against_pg, :decimal, precision: 6, scale: 3
    change_column :team_statlines, :shots_percent, :decimal, precision: 6, scale: 3
  end
end
