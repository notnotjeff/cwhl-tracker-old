class AddPrecisionToGfBreakdown < ActiveRecord::Migration[5.1]
  def change
    change_column :skaters, :gf_p_6v5, :decimal, precision: 5, scale: 2
    change_column :skaters, :gf_p_5v6, :decimal, precision: 5, scale: 2
    change_column :skaters, :gf_p_5v5, :decimal, precision: 5, scale: 2
    change_column :skaters, :gf_p_5v4, :decimal, precision: 5, scale: 2
    change_column :skaters, :gf_p_4v5, :decimal, precision: 5, scale: 2
    change_column :skaters, :gf_p_4v3, :decimal, precision: 5, scale: 2
    change_column :skaters, :gf_p_3v4, :decimal, precision: 5, scale: 2
    change_column :skaters, :gf_p_3v3, :decimal, precision: 5, scale: 2
    change_column :skaters, :gf_p_5v3, :decimal, precision: 5, scale: 2
    change_column :skaters, :gf_p_3v5, :decimal, precision: 5, scale: 2
    change_column :skaters, :gf_p_6v3, :decimal, precision: 5, scale: 2
    change_column :skaters, :gf_p_3v6, :decimal, precision: 5, scale: 2
    change_column :skaters, :gf_p_es, :decimal, precision: 5, scale: 2
    change_column :skaters, :gf_p_pp, :decimal, precision: 5, scale: 2
    change_column :skaters, :gf_p_pk, :decimal, precision: 5, scale: 2
  end
end
