class CreateCoaches < ActiveRecord::Migration[5.1]
  def change
    create_table :coaches do |t|
      t.integer :team_id
      t.integer :season_id
      t.string :first_name
      t.string :last_name
      t.string :role

      t.timestamps
    end
  end
end
