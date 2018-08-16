class AddRateStatsToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :goals_pg, :float
    add_column :players, :a1_pg, :float
    add_column :players, :a2_pg, :float
    add_column :players, :points_pg, :float
    add_column :players, :ev_goals_pg, :float
    add_column :players, :ev_a1_pg, :float
    add_column :players, :ev_a2_pg, :float
    add_column :players, :ev_points_pg, :float
    add_column :players, :pp_goals_pg, :float
    add_column :players, :pp_a1_pg, :float
    add_column :players, :pp_a2_pg, :float
    add_column :players, :sh_goals_pg, :float
    add_column :players, :sh_a1_pg, :float
    add_column :players, :sh_a2_pg, :float
    add_column :players, :sh_points_pg, :float
    add_column :players, :shots_pg, :float
  end
end
