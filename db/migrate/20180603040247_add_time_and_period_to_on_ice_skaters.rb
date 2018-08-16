class AddTimeAndPeriodToOnIceSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :on_ice_skaters, :period, :integer
    add_column :on_ice_skaters, :time, :integer
  end
end
