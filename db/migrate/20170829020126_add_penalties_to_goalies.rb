class AddPenaltiesToGoalies < ActiveRecord::Migration[5.1]
  def change
    add_column :goalies, :penalties, :integer
  end
end
