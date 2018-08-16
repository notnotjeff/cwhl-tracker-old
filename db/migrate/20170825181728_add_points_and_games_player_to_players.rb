class AddPointsAndGamesPlayerToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :points, :integer
    add_column :players, :ev_points, :integer
    add_column :players, :pp_points, :integer
    add_column :players, :sh_points, :integer
    add_column :players, :ps_goals, :integer
    add_column :players, :ps_taken, :integer
    add_column :players, :games_played, :integer
    add_column :players, :penalties_taken, :integer
    add_column :players, :penalty_minutes, :integer
  end
end
