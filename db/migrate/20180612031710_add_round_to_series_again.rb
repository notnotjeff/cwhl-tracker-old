class AddRoundToSeriesAgain < ActiveRecord::Migration[5.1]
  def change
    add_column :series, :round, :integer
  end
end
