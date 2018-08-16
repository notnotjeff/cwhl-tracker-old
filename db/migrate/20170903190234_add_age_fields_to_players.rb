class AddAgeFieldsToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :season_age, :decimal, precision: 4, scale: 1
    add_column :players, :dob, :date
  end
end
