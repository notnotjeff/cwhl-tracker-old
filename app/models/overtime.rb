class Overtime < ApplicationRecord
	validates :cwhl_game_id, uniqueness: { scope: [:overtime_number, :cwhl_game_id] }
	belongs_to :game, primary_key: :cwhl_game_id,
										foreign_key: :cwhl_game_id,
										optional: true
end
