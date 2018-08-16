class TeamGameStatline < ApplicationRecord
	validates :game_id, uniqueness: { scope: [:team_id] }

	belongs_to :game, primary_key: :cwhl_game_id,
										foreign_key: :game_id,
											optional: true

	def game_abbreviation
		return self.game.game_abbreviation
	end

	def result
		result = ""

		if self.overtime == true && self.shootout == false
			result += "OT"
		elsif self.shootout == true
			result += "SO"
		end

		if self.won == true
			result += "W"
		else
			result += "L"
		end
		return result
	end
	
end
