class AddTeamIdToTeamStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :team_statlines, :team_id, :integer
  end
end
