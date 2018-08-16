class Add4v4StatsToSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :gf_4v4, :integer
    add_column :skaters, :ga_4v4, :integer
    add_column :skaters, :gf_p_4v4, :decimal
  end
end
