class CreateOnIceSkaters < ActiveRecord::Migration[5.1]
  def change
    create_table :on_ice_skaters do |t|
      t.integer :goal_id
      t.integer :game_id
      t.integer :season_id
      t.integer :player_id
      t.integer :team_id
      t.boolean :on_scoring_team
      t.boolean :is_powerplay
      t.boolean :is_empty_net
      t.boolean :is_shorthanded

      t.timestamps
    end
  end
end
