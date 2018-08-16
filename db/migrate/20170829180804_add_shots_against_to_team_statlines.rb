class AddShotsAgainstToTeamStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :team_statlines, :shots_against, :integer
  end
end
