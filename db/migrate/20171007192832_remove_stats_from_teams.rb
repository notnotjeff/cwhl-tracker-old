class RemoveStatsFromTeams < ActiveRecord::Migration[5.1]
  def change
  	remove_column :teams, :first_period_shots_pg, :integer
  	remove_column :teams, :second_period_shots_pg, :integer
  	remove_column :teams, :third_period_shots_pg, :integer
  	remove_column :teams, :ot_period_shots_pg, :integer
  end
end
