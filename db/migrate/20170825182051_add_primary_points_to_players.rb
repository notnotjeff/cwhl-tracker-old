class AddPrimaryPointsToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :pr_points, :integer
    add_column :players, :ev_pr_points, :integer
    add_column :players, :pp_pr_points, :integer
    add_column :players, :sh_pr_points, :integer
  end
end
