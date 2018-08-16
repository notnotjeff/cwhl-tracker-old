class ShootoutAttempt < ApplicationRecord
	validates :game_id, uniqueness: { scope: [:shot_number, :player_id, :season_id] }

	belongs_to :game, primary_key: :cwhl_game_id,
										foreign_key: :game_id,
											optional: true

	def scored_in_words
		if self.scored == true
			return "Scored"
		else
			return "Missed"
		end
	end

	def shooter_name
		Skater.find_by(player_id: self.player_id).full_name
	end
end
