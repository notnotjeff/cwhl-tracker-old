class RenamePlayersTableToSkaters < ActiveRecord::Migration[5.1]
  def self.up
    rename_table :players, :skaters
  end

  def self.down
    rename_table :skaters, :players
  end
end
