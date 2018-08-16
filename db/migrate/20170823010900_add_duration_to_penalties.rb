class AddDurationToPenalties < ActiveRecord::Migration[5.1]
  def change
    add_column :penalties, :duration, :integer
  end
end
