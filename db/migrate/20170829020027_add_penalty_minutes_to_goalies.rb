class AddPenaltyMinutesToGoalies < ActiveRecord::Migration[5.1]
  def change
  	add_column :goalies, :penalty_minutes, :integer
  end
end
