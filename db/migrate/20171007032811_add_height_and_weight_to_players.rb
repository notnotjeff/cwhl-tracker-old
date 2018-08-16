class AddHeightAndWeightToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :height, :string
    add_column :players, :weight, :integer
  end
end
