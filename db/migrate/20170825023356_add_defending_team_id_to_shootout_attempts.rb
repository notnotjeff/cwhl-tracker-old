class AddDefendingTeamIdToShootoutAttempts < ActiveRecord::Migration[5.1]
  def change
    add_column :shootout_attempts, :defending_team_id, :integer
  end
end
