class CreateSeasons < ActiveRecord::Migration[5.1]
  def change
    create_table :seasons do |t|
      t.integer :year_start
      t.integer :year_end
      t.string :name
      t.integer :ahl_id

      t.timestamps
    end
  end
end
