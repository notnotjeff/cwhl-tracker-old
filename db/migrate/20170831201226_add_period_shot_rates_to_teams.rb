class AddPeriodShotRatesToTeams < ActiveRecord::Migration[5.1]
  def change
    add_column :teams, :first_period_shots_pg, :decimal
    add_column :teams, :second_period_shots_pg, :decimal
    add_column :teams, :third_period_shots_pg, :decimal
    add_column :teams, :ot_period_shots_pg, :decimal
    change_column :team_statlines, :shots_pg, :decimal, precision: 5, scale: 2
    change_column :team_statlines, :shots_against_pg, :decimal, precision: 5, scale: 2
  end
end
