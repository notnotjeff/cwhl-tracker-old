class AddPrecisionToTeamStatlines < ActiveRecord::Migration[5.1]
  def change
  	change_column :team_statlines, :shots_pg, :decimal, precision: 5, scale: 2
    change_column :team_statlines, :shots_against_pg, :decimal, precision: 5, scale: 2
    change_column :team_statlines, :shots_percent, :decimal, precision: 5, scale: 2
  end
end
