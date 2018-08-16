class CreateShootoutAttempts < ActiveRecord::Migration[5.1]
  def change
    create_table :shootout_attempts do |t|
      t.integer :game_id
      t.integer :season_id
      t.integer :team_id
      t.integer :player_id
      t.integer :goalie_id
      t.boolean :scored
      t.boolean :game_winner
      t.integer :shot_number

      t.timestamps
    end
  end
end
