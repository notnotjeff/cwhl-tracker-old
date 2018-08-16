class AddIndexToShootoutAttemptsByGameAndTeam < ActiveRecord::Migration[5.1]
  def change
    add_index :shootout_attempts, [:game_id, :team_id]
  end
end
