class AddIndexToOnIceSkatersPlayerId < ActiveRecord::Migration[5.1]
  def change
    add_index :on_ice_skaters, :player_id
  end
end
