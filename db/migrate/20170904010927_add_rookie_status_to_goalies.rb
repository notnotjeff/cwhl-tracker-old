class AddRookieStatusToGoalies < ActiveRecord::Migration[5.1]
  def change
    add_column :goalies, :is_rookie, :boolean, default: false
  end
end
