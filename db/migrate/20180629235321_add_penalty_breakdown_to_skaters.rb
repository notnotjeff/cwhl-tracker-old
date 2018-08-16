class AddPenaltyBreakdownToSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :minors, :integer
    add_column :skaters, :minors_pg, :decimal, precision: 5, scale: 2, default: 0
    add_column :skaters, :double_minors, :integer
    add_column :skaters, :double_minors_pg, :decimal, precision: 5, scale: 2, default: 0
    add_column :skaters, :majors, :integer
    add_column :skaters, :majors_pg, :decimal, precision: 5, scale: 2, default: 0
    add_column :skaters, :fights, :integer
    add_column :skaters, :fights_pg, :decimal, precision: 5, scale: 2, default: 0
    add_column :skaters, :misconducts, :integer
    add_column :skaters, :misconducts_pg, :decimal, precision: 5, scale: 2, default: 0
    add_column :skaters, :game_misconducts, :integer
    add_column :skaters, :game_misconducts_pg, :decimal, precision: 5, scale: 2, default: 0
  end
end
