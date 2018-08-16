class AddReceivedPointToOnIceSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :on_ice_skaters, :received_point, :boolean
  end
end
