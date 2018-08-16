class ChangeEnfEnaRawToIntegerSecondTry < ActiveRecord::Migration[5.1]
  def change
    change_column :skaters, :gf_enf, :integer
    change_column :skaters, :ga_enf, :integer
    change_column :skaters, :gf_ena, :integer
    change_column :skaters, :ga_ena, :integer
  end
end
