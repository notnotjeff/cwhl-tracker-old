class ChangeDescriptionInPenaltiesToString < ActiveRecord::Migration[5.1]
  def change
  	change_column :penalties, :description, :string
  end
end
