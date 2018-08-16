class Referee < ApplicationRecord
	validates :game_id, uniqueness: { scope: [:first_name, :last_name, :number] }
	belongs_to :game, primary_key: :cwhl_game_id,
										foreign_key: :game_id,
											optional: true
end
