class GoalieGameStatline < ApplicationRecord
	validates :game_id, uniqueness: { scope: [:player_id, :season_id] }

	belongs_to :game, primary_key: :cwhl_game_id,
										foreign_key: :game_id,
											optional: true
	belongs_to :goalie, primary_key: :player_id,
											foreign_key: :player_id,
											optional: true
	belongs_to :player, 	primary_key: :cwhl_id,
												foreign_key: :player_id,
												optional: true
												
	def full_name
		return self.first_name + " " + self.last_name
	end

	def starting_star
		if self.starting == true
			return "*"
		else
			return ""
		end
	end

	def time_in_minutes
		minutes = self.time_on_ice / 60
		seconds = self.time_on_ice % 60

		if seconds < 10
			seconds = "0" + seconds.to_s
		end

		t = minutes.to_s + ":" + seconds.to_s
		return t
	end

	def save_percent_to_percentage
		sp = self.save_percent * 100
		return "#{sp}%"
	end
end
