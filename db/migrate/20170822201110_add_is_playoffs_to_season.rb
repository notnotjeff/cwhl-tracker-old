class AddIsPlayoffsToSeason < ActiveRecord::Migration[5.1]
  def change
    add_column :seasons, :is_playoffs, :boolean
  end
end
