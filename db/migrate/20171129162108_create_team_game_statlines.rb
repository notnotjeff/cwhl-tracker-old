class CreateTeamGameStatlines < ActiveRecord::Migration[5.1]
  def change
    create_table :team_game_statlines do |t|
      t.integer :game_id
      t.integer :season_id
      t.integer :team_id
      t.string :abbreviation
      t.datetime :game_date
      t.boolean :home_team
      t.boolean :overtime
      t.boolean :shootout
      t.integer :goals_for
      t.integer :goals_against
      t.integer :p1_goals
      t.integer :p2_goals
      t.integer :p3_goals
      t.integer :p1_goals_against
      t.integer :p2_goals_against
      t.integer :p3_goals_against
      t.integer :shots_for
      t.integer :shots_against
      t.integer :p1_shots
      t.integer :p2_shots
      t.integer :p3_shots
      t.integer :p1_shots_against
      t.integer :p2_shots_against
      t.integer :p3_shots_against
      t.integer :ev_goals
      t.integer :ev_goals_against
      t.integer :pp_goals
      t.integer :pp_goals_against
      t.integer :sh_goals
      t.integer :sh_goals_against
      t.integer :en_goals
      t.integer :en_goals_against

      t.timestamps
    end
  end
end
