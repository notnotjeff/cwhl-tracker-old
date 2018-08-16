class AddGf5v5RelToSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :gf_5v5_rel, :decimal, precision: 5, scale: 2
  end
end
