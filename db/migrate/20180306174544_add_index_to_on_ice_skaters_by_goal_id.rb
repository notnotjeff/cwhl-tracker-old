class AddIndexToOnIceSkatersByGoalId < ActiveRecord::Migration[5.1]
  def change
    add_index :on_ice_skaters, :goal_id
  end
end
