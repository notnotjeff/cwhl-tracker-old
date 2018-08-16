class AddExtraDigitToSvPercent < ActiveRecord::Migration[5.1]
  def change
  	change_column :goalies, :save_percentage, :decimal, precision: 6, scale: 3, default: 0
  end
end
