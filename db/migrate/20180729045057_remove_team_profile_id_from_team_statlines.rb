class RemoveTeamProfileIdFromTeamStatlines < ActiveRecord::Migration[5.1]
  def change
    remove_column :team_statlines, :team_profile_id
  end
end
