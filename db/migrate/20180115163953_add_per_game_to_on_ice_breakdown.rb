class AddPerGameToOnIceBreakdown < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :gf_es_pg, :decimal, precision: 5, scale: 2
    add_column :skaters, :ga_es_pg, :decimal, precision: 5, scale: 2
    add_column :skaters, :gf_pp_pg, :decimal, precision: 5, scale: 2
    add_column :skaters, :ga_pp_pg, :decimal, precision: 5, scale: 2
    add_column :skaters, :gf_pk_pg, :decimal, precision: 5, scale: 2
    add_column :skaters, :ga_pk_pg, :decimal, precision: 5, scale: 2
  end
end
