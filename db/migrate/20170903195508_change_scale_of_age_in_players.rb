class ChangeScaleOfAgeInPlayers < ActiveRecord::Migration[5.1]
  def change
  	change_column :players, :season_age, :decimal, precision: 5, scale: 2
  end
end
