class AddSkaterCountToOnIceSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :on_ice_skaters, :teammate_count, :integer
    add_column :on_ice_skaters, :opposing_skaters_count, :integer
  end
end
