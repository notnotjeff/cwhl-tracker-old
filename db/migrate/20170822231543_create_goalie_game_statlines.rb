class CreateGoalieGameStatlines < ActiveRecord::Migration[5.1]
  def change
    create_table :goalie_game_statlines do |t|
      t.integer :player_id
      t.integer :team_id
      t.integer :season_id
      t.integer :game_id
      t.string :first_name
      t.string :last_name
      t.string :position
      t.integer :number
      t.string :captaincy
      t.integer :shots_against
      t.integer :goals_against
      t.integer :saves
      t.integer :time_on_ice
      t.boolean :starting

      t.timestamps
    end
  end
end
