class Star < ApplicationRecord
	validates :game_id, uniqueness: { scope: :player_id }
	belongs_to :game, primary_key: :cwhl_game_id,
										foreign_key: :game_id,
											optional: true
end
