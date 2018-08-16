class AddPenaltyBreakdownToTeamStatlinesTable < ActiveRecord::Migration[5.1]
  def change
    add_column :team_statlines, :minors, :integer
    add_column :team_statlines, :minors_pg, :decimal, precision: 5, scale: 2, default: 0
    add_column :team_statlines, :double_minors, :integer
    add_column :team_statlines, :double_minors_pg, :decimal, precision: 5, scale: 2, default: 0
    add_column :team_statlines, :majors, :integer
    add_column :team_statlines, :majors_pg, :decimal, precision: 5, scale: 2, default: 0
    add_column :team_statlines, :fights, :integer
    add_column :team_statlines, :fights_pg, :decimal, precision: 5, scale: 2, default: 0
    add_column :team_statlines, :misconducts, :integer
    add_column :team_statlines, :misconducts_pg, :decimal, precision: 5, scale: 2, default: 0
    add_column :team_statlines, :game_misconducts, :integer
    add_column :team_statlines, :game_misconducts_pg, :decimal, precision: 5, scale: 2, default: 0
  end
end
