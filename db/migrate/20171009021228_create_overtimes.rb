class CreateOvertimes < ActiveRecord::Migration[5.1]
  def change
    create_table :overtimes do |t|
      t.integer :game_id
      t.integer :ahl_game_id
      t.integer :season_id
      t.integer :home_team_id
      t.integer :visiting_team_id
      t.integer :overtime_number
      t.integer :home_shots
      t.integer :home_goals
      t.integer :visitor_shots
      t.integer :visitor_goals

      t.timestamps
    end
  end
end
