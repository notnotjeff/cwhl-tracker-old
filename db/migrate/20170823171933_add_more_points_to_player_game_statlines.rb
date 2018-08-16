class AddMorePointsToPlayerGameStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :player_game_statlines, :pp_goals, :integer
    add_column :player_game_statlines, :pp_a1, :integer
    add_column :player_game_statlines, :pp_a2, :integer
    add_column :player_game_statlines, :sh_goals, :integer
    add_column :player_game_statlines, :sh_a1, :integer
    add_column :player_game_statlines, :sh_a2, :integer
    add_column :player_game_statlines, :ps_goals, :integer
    add_column :player_game_statlines, :points, :integer
    add_column :player_game_statlines, :ev_points, :integer
    add_column :player_game_statlines, :pp_points, :integer
    add_column :player_game_statlines, :sh_points, :integer
  end
end
