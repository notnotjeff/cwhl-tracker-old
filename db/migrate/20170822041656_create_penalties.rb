class CreatePenalties < ActiveRecord::Migration[5.1]
  def change
    create_table :penalties do |t|
      t.integer :game_id
      t.integer :season_id
      t.integer :team_id
      t.integer :player_id
      t.integer :serving_player_id
      t.integer :drawing_team_id
      t.integer :period
      t.integer :time
      t.integer :description
      t.integer :team_score
      t.integer :opposing_team_score

      t.timestamps
    end
  end
end
