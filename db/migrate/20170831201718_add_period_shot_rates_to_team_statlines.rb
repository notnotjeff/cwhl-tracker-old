class AddPeriodShotRatesToTeamStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :team_statlines, :first_period_shots_pg, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :second_period_shots_pg, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :third_period_shots_pg, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :ot_period_shots_pg, :decimal, precision: 5, scale: 2
  end
end
