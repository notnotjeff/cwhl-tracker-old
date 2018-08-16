class PlayerGameStatline < ApplicationRecord
	validates :game_id, uniqueness: { scope: [:player_id, :season_id] }

	belongs_to :game, primary_key: :cwhl_game_id,
										foreign_key: :game_id,
											optional: true
	belongs_to :skater, primary_key: :player_id,
											foreign_key: :player_id,
											optional: true
	belongs_to :player, primary_key: :cwhl_id,
											foreign_key: :player_id,
											optional: true

	def full_name
		return self.first_name + " " + self.last_name
	end
end
