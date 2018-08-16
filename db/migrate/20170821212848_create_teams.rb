class CreateTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :teams do |t|
      t.string :city
      t.string :game_file_city
      t.string :name
      t.string :abbreviation
      t.integer :division_id
      t.integer :team_code

      t.timestamps
    end
  end
end
