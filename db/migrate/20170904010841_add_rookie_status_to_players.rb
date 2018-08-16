class AddRookieStatusToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :is_rookie, :boolean, default: false
  end
end
