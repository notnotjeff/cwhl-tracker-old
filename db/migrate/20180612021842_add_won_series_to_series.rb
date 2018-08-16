class AddWonSeriesToSeries < ActiveRecord::Migration[5.1]
  def change
    add_column :series, :won_series, :boolean
  end
end
