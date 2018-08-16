class ChangeEnfEnaRawToInteger < ActiveRecord::Migration[5.1]
  def change
    change_column :skaters, :gf_enf, :decimal
    change_column :skaters, :ga_enf, :decimal
    change_column :skaters, :gf_ena, :decimal
    change_column :skaters, :ga_ena, :decimal
  end
end
