class AddHandednessToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :shoots, :string
  end
end
