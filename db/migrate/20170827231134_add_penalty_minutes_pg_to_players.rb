class AddPenaltyMinutesPgToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :penalty_minutes_pg, :float
  end
end
