class AddSavesPgToGoalies < ActiveRecord::Migration[5.1]
  def change
    add_column :goalies, :saves_pg, :decimal, precision: 5, scale: 2
  end
end
