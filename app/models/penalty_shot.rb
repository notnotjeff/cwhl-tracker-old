class PenaltyShot < ApplicationRecord
	validates :game_id, uniqueness: { scope: [:time, :period, :player_id, :season_id] }

	belongs_to :game,	primary_key: :cwhl_game_id,
										foreign_key: :game_id,
										optional: true

	def time_in_minutes
		minutes = self.time / 60
		seconds = self.time % 60

		if seconds < 10
			seconds = "0" + seconds.to_s
		end

		t = minutes.to_s + ":" + seconds.to_s
		return t
	end

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
