class AddEndDateToSeasons < ActiveRecord::Migration[5.1]
  def change
    add_column :seasons, :end_date, :date
  end
end
