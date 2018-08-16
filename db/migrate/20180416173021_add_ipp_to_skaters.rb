class AddIppToSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :as_ipp, :decimal, precision: 5, scale: 2
    add_column :skaters, :es_ipp, :decimal, precision: 5, scale: 2
    add_column :skaters, :pp_ipp, :decimal, precision: 5, scale: 2
  end
end
