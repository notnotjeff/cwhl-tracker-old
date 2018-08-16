class AddPpPkEsToSkatersGfP < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :gf_es, :integer
    add_column :skaters, :ga_es, :integer
    add_column :skaters, :gf_p_es, :decimal
    add_column :skaters, :gf_pp, :integer
    add_column :skaters, :ga_pp, :integer
    add_column :skaters, :gf_p_pp, :decimal
    add_column :skaters, :gf_pk, :integer
    add_column :skaters, :ga_pk, :integer
    add_column :skaters, :gf_p_pk, :decimal
  end
end
