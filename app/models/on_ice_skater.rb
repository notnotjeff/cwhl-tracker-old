class OnIceSkater < ApplicationRecord
	validates :goal_id, uniqueness: { scope: [:game_id, :player_id] }

	belongs_to :goal, optional: true
	belongs_to :game, primary_key: :cwhl_game_id,
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

	def result
		self.on_scoring_team ? 'GF' : 'GA'
	end
end
