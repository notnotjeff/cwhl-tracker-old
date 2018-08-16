class AddTeamProfileIdToTeamStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :team_statlines, :team_profile_id, :integer
  end
end
