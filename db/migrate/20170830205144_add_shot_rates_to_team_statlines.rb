class AddShotRatesToTeamStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :team_statlines, :shots_pg, :decimal
    add_column :team_statlines, :shots_against_pg, :decimal
    add_column :team_statlines, :shots_percent, :decimal
  end
end
