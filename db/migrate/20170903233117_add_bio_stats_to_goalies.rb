class AddBioStatsToGoalies < ActiveRecord::Migration[5.1]
  def change
    add_column :goalies, :shoots, :string
    add_column :goalies, :height, :string
    add_column :goalies, :weight, :integer
    add_column :goalies, :dob, :date
    add_column :goalies, :season_age, :decimal, precision: 5, scale: 2
  end
end
