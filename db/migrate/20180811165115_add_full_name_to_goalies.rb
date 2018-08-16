class AddFullNameToGoalies < ActiveRecord::Migration[5.1]
  def change
    add_column :goalies, :full_name, :string
  end
end
