class AddPointsToPlayer < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :goals, :integer
    add_column :players, :a1, :integer
    add_column :players, :a2, :integer
    add_column :players, :ev_goals, :integer
    add_column :players, :ev_a1, :integer
    add_column :players, :ev_a2, :integer
    add_column :players, :pp_goals, :integer
    add_column :players, :pp_a1, :integer
    add_column :players, :pp_a2, :integer
    add_column :players, :sh_goals, :integer
    add_column :players, :sh_a1, :integer
    add_column :players, :sh_a2, :integer
    add_column :players, :shots, :integer
  end
end
