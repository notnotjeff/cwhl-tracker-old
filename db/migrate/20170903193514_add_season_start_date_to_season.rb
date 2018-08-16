class AddSeasonStartDateToSeason < ActiveRecord::Migration[5.1]
  def change
    add_column :seasons, :start_date, :date
  end
end
