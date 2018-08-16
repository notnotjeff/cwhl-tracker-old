class AddShootingAndSavePercentageToTeamStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :team_statlines, :shooting_percent, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :save_percent, :decimal, precision: 5, scale: 2
  end
end
