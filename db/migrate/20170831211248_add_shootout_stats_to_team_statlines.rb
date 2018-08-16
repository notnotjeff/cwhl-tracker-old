class AddShootoutStatsToTeamStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :team_statlines, :shootout_attempts, :integer
    add_column :team_statlines, :shootout_goals, :integer
    add_column :team_statlines, :shootout_percent, :decimal
  end
end
