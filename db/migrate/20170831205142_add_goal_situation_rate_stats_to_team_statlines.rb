class AddGoalSituationRateStatsToTeamStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :team_statlines, :goals_for_pg, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :goals_against_pg, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :ev_goals_for_pg, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :ev_goals_against_pg, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :pp_goals_for_pg, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :pp_goals_against_pg, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :sh_goals_for_pg, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :sh_goals_against_pg, :decimal, precision: 5, scale: 2
  end
end
