class AddBioInfoToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :ahl_id, :integer
    add_column :players, :first_name, :string
    add_column :players, :last_name, :string
    add_column :players, :position, :string
    add_column :players, :birthdate, :date
  end
end
