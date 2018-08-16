class ChangeOtShotsAgainstToInteger < ActiveRecord::Migration[5.1]
  def change
    change_column :team_game_statlines, :ot_shots_against, 'integer USING CAST(ot_shots_against AS integer)'
  end
end
