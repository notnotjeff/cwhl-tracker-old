class AddNumberToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :number, :integer
  end
end
