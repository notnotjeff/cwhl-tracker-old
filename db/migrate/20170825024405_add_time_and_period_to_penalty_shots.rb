class AddTimeAndPeriodToPenaltyShots < ActiveRecord::Migration[5.1]
  def change
    add_column :penalty_shots, :time, :integer
    add_column :penalty_shots, :period, :integer
  end
end
