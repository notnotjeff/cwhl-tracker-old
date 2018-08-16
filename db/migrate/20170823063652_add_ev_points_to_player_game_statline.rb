class AddEvPointsToPlayerGameStatline < ActiveRecord::Migration[5.1]
  def change
    add_column :player_game_statlines, :ev_goals, :integer
    add_column :player_game_statlines, :ev_a1, :integer
    add_column :player_game_statlines, :ev_a2, :integer
  end
end
