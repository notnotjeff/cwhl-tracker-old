class AddEmptyNetOnIceBreakdown < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :gf_enf, :decimal, precision: 5, scale: 2
    add_column :skaters, :ga_enf, :decimal, precision: 5, scale: 2
    add_column :skaters, :gf_p_enf, :decimal, precision: 5, scale: 2
    add_column :skaters, :gf_ena, :decimal, precision: 5, scale: 2
    add_column :skaters, :ga_ena, :decimal, precision: 5, scale: 2
    add_column :skaters, :gf_p_ena, :decimal, precision: 5, scale: 2
  end
end
