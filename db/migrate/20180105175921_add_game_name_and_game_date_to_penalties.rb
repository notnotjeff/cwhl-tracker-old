class AddGameNameAndGameDateToPenalties < ActiveRecord::Migration[5.1]
  def change
    add_column :penalties, :game_name, :string
    add_column :penalties, :game_date, :datetime
  end
end
