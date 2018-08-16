class AddPenaltyShotAttemptsToGoalies < ActiveRecord::Migration[5.1]
  def change
    add_column :goalies, :penalty_shot_attempts, :integer
  end
end
