class AddScaleAndPrecisionTo4v4GfP < ActiveRecord::Migration[5.1]
  def change
    change_column :skaters, :gf_p_4v4, :decimal, precision: 5, scale: 2
  end
end
