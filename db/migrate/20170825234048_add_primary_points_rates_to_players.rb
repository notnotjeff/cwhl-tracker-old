class AddPrimaryPointsRatesToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :pr_points_pg, :float
    add_column :players, :ev_pr_points_pg, :float
    add_column :players, :pp_pr_points_pg, :float
    add_column :players, :sh_pr_points_pg, :float
  end
end
