class ChangePrecisionOfTeamStatlines < ActiveRecord::Migration[5.1]
  def change
  	change_column :team_statlines, :points_percentage, :decimal, precision: 5, scale: 2
  end
end
