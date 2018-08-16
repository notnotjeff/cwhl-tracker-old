class AddPeriodGoalsToTeamStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :team_statlines, :first_period_goals, :integer
    add_column :team_statlines, :second_period_goals, :integer
    add_column :team_statlines, :third_period_goals, :integer
    add_column :team_statlines, :ot_period_goals, :integer
    add_column :team_statlines, :first_period_goals_pg, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :second_period_goals_pg, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :third_period_goals_pg, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :ot_period_goals_pg, :decimal, precision: 5, scale: 2
  end
end
