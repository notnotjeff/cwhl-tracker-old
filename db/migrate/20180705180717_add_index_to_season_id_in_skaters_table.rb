class AddIndexToSeasonIdInSkatersTable < ActiveRecord::Migration[5.1]
  def change
    add_index :skaters, :season_id
  end
end
