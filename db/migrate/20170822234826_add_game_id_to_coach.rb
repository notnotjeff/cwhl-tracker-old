class AddGameIdToCoach < ActiveRecord::Migration[5.1]
  def change
    add_column :coaches, :game_id, :integer
  end
end
