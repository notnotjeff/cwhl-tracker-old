class ChangeStringsToIntegersGamesTable < ActiveRecord::Migration[5.1]
  def change
  	change_column :games, :home_team_id, 'integer USING CAST(home_team_id AS integer)'
  	change_column :games, :visiting_team_id, 'integer USING CAST(visiting_team_id AS integer)'
  	change_column :games, :duration, 'integer USING CAST(duration AS integer)'
  end
end
