class AddColumnsToSeries < ActiveRecord::Migration[5.1]
  def change
    add_column :series, :team_id, :integer
    add_column :series, :opposing_team_id, :integer
    add_column :series, :wins, :integer
    add_column :series, :losses, :integer
    add_column :series, :gf, :integer
    add_column :series, :ga, :integer
    add_column :series, :gf_p, :decimal
    add_column :series, :sf, :integer
    add_column :series, :sa, :integer
    add_column :series, :sf_p, :decimal
    add_column :series, :shooting_percent, :decimal
    add_column :series, :save_percent, :decimal
  end
end
