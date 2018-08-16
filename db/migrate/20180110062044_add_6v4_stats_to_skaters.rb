class Add6v4StatsToSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :gf_6v4, :integer
    add_column :skaters, :ga_6v4, :integer
    add_column :skaters, :gf_p_6v4, :decimal
    add_column :skaters, :gf_4v6, :integer
    add_column :skaters, :ga_4v6, :integer
    add_column :skaters, :gf_p_4v6, :decimal
  end
end
