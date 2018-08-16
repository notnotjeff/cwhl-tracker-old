class AddPenaltyTypesToPenalties < ActiveRecord::Migration[5.1]
  def change
    add_column :penalties, :is_minor, :boolean
    add_column :penalties, :is_double_minor, :boolean
    add_column :penalties, :is_major, :boolean
    add_column :penalties, :is_fight, :boolean
    add_column :penalties, :is_game_misconduct, :boolean
    add_column :penalties, :is_misconduct, :boolean
  end
end
