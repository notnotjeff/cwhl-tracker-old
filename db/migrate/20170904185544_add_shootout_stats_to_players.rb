class AddShootoutStatsToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :shootout_attempts, :integer
    add_column :players, :shootout_goals, :integer
    add_column :players, :shootout_percent, :decimal, precision: 5, scale: 3
    add_column :players, :shootout_game_winners, :integer
  end
end
