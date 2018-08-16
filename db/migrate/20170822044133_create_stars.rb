class CreateStars < ActiveRecord::Migration[5.1]
  def change
    create_table :stars do |t|
      t.integer :game_id
      t.integer :season_id
      t.integer :team_id
      t.integer :player_id
      t.integer :number

      t.timestamps
    end
  end
end
