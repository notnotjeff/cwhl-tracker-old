class AddRelToSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :gf_es_rel, :decimal, precision: 5, scale: 2
    add_column :skaters, :gf_pp_rel, :decimal, precision: 5, scale: 2
    add_column :skaters, :gf_pk_rel, :decimal, precision: 5, scale: 2
  end
end
