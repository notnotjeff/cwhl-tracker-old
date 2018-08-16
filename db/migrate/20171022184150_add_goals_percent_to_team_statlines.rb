class AddGoalsPercentToTeamStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :team_statlines, :goals_percent, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :ev_goals_percent, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :pdo, :decimal, precision: 5, scale: 2
  end
end
