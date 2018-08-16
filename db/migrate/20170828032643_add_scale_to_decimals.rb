class AddScaleToDecimals < ActiveRecord::Migration[5.1]
  def change
  	change_column :players, :goals_pg, :decimal, precision: 5, scale: 2
    change_column :players, :a1_pg, :decimal, precision: 5, scale: 2
    change_column :players, :a2_pg, :decimal, precision: 5, scale: 2
    change_column :players, :points_pg, :decimal, precision: 5, scale: 2
    change_column :players, :ev_goals_pg, :decimal, precision: 5, scale: 2
    change_column :players, :ev_a1_pg, :decimal, precision: 5, scale: 2
    change_column :players, :ev_a2_pg, :decimal, precision: 5, scale: 2
    change_column :players, :ev_points_pg, :decimal, precision: 5, scale: 2
    change_column :players, :pp_goals_pg, :decimal, precision: 5, scale: 2
    change_column :players, :pp_a1_pg, :decimal, precision: 5, scale: 2
    change_column :players, :pp_a2_pg, :decimal, precision: 5, scale: 2
    change_column :players, :sh_goals_pg, :decimal, precision: 5, scale: 2
    change_column :players, :sh_a1_pg, :decimal, precision: 5, scale: 2
    change_column :players, :sh_a2_pg, :decimal, precision: 5, scale: 2
    change_column :players, :sh_points_pg, :decimal, precision: 5, scale: 2
    change_column :players, :shots_pg, :decimal, precision: 5, scale: 2
    change_column :players, :pr_points_pg, :decimal, precision: 5, scale: 2
    change_column :players, :ev_pr_points_pg, :decimal, precision: 5, scale: 2
    change_column :players, :pp_pr_points_pg, :decimal, precision: 5, scale: 2
    change_column :players, :sh_pr_points_pg, :decimal, precision: 5, scale: 2
    change_column :players, :pp_points_pg, :decimal, precision: 5, scale: 2
    change_column :players, :penalty_minutes_pg, :decimal, precision: 5, scale: 2
  end
end
