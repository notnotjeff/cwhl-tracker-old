class CreateTeamStatlines < ActiveRecord::Migration[5.1]
  def change
    create_table :team_statlines do |t|
      t.string :name
      t.string :city
      t.string :abbreviation
      t.integer :division_id
      t.integer :team_code
      t.integer :season_id
      t.integer :games_played
      t.integer :wins
      t.integer :losses
      t.integer :ot_losses
      t.integer :so_losses
      t.integer :points
      t.decimal :points_percentage
      t.integer :row
      t.integer :goals_for
      t.integer :goals_against
      t.integer :ev_goals_for
      t.integer :ev_goals_against
      t.integer :sh_goals_for
      t.integer :sh_goals_against
      t.integer :pp_goals_for
      t.string :pp_goals_against
      t.integer :penalty_minutes
      t.integer :shots
      t.integer :first_period_shots
      t.integer :second_period_shots
      t.integer :third_period_shots
      t.integer :ot_shots

      t.timestamps
    end
  end
end
