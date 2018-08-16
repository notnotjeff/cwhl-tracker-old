class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.integer :ahl_game_id
      t.datetime :game_date
      t.integer :game_number
      t.string :venue
      t.integer :attendance
      t.string :start_time
      t.string :end_time
      t.string :duration
      t.string :home_team_id
      t.string :visiting_team_id
      t.boolean :overtime
      t.boolean :shootout
      t.integer :periods
      t.integer :home_score
      t.integer :visitor_score
      t.integer :season_id

      t.timestamps
    end
  end
end
