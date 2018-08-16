class CreatePenaltyShots < ActiveRecord::Migration[5.1]
  def change
    create_table :penalty_shots do |t|
      t.integer :player_id
      t.integer :game_id
      t.integer :season_id
      t.integer :goalie_id
      t.boolean :scored
      t.integer :team_id
      t.integer :defending_team_id

      t.timestamps
    end
  end
end
