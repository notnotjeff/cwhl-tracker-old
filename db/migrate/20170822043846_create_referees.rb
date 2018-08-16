class CreateReferees < ActiveRecord::Migration[5.1]
  def change
    create_table :referees do |t|
      t.integer :number
      t.string :position
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
