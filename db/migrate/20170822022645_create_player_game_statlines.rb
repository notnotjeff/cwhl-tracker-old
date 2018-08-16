class CreatePlayerGameStatlines < ActiveRecord::Migration[5.1]
  def change
    create_table :player_game_statlines do |t|
      t.integer :game_id
      t.integer :team_id
      t.integer :player_id
      t.string :first_name
      t.string :last_name
      t.integer :number
      t.string :position
      t.integer :goals
      t.integer :a1
      t.integer :a2
      t.integer :shots
      t.string :captaincy

      t.timestamps
    end
  end
end
