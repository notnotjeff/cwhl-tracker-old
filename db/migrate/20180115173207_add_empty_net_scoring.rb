class AddEmptyNetScoring < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :en_goals, :integer
    add_column :skaters, :en_a1, :integer
    add_column :skaters, :en_a2, :integer
    add_column :skaters, :en_points, :integer
  end
end
