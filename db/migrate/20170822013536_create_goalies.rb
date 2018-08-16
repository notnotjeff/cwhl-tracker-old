class CreateGoalies < ActiveRecord::Migration[5.1]
  def change
    create_table :goalies do |t|
      t.integer :player_id
      t.integer :team_id
      t.integer :season_id
      t.string :first_name
      t.string :last_name
      t.string :position
      t.integer :number
      t.string :captaincy
      t.integer :shots_against
      t.integer :goals_against
      t.integer :saves
      t.integer :time_on_ice
      t.integer :goals
      t.integer :assists
      t.integer :points
      t.decimal :shots_against_pg, precision: 5, scale: 2
      t.decimal :goals_against_average, precision: 5, scale: 2
      t.decimal :save_percentage, precision: 5, scale: 2

      t.timestamps
    end
  end
end
