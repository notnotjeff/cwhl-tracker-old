class CreateGoals < ActiveRecord::Migration[5.1]
  def change
    create_table :goals do |t|
      t.integer :game_id
      t.integer :team_id
      t.integer :season_id
      t.integer :goalscorer_id
      t.integer :a1_id
      t.integer :a2_id
      t.integer :opposing_team_id
      t.integer :team_score
      t.integer :opposing_team_score
      t.integer :period
      t.integer :time
      t.boolean :is_empty_net
      t.boolean :is_powerplay
      t.boolean :is_shorthanded
      t.boolean :is_penalty_shot
      t.integer :team_player_count
      t.integer :opposing_team_player_count

      t.timestamps
    end
  end
end
