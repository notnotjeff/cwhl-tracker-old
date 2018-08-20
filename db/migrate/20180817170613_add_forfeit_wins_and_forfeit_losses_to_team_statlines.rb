class AddForfeitWinsAndForfeitLossesToTeamStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :team_statlines, :forfeit_wins, :integer
    add_column :team_statlines, :forfeit_losses, :integer
  end
end
