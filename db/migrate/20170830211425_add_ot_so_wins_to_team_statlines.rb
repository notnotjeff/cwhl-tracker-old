class AddOtSoWinsToTeamStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :team_statlines, :ot_wins, :integer
    add_column :team_statlines, :so_wins, :integer
  end
end
