class Penalty < ApplicationRecord
	validates :game_id, presence: true

	belongs_to :game, primary_key: :cwhl_game_id,
										foreign_key: :game_id,
											optional: true
	belongs_to :player, primary_key: :cwhl_id,
											foreign_key: :player_id,
											optional: true

	def duration_in_minutes
		return "-" if self.duration.nil?
		minutes = self.duration / 60

		return "#{minutes}:00"
	end

	def time_in_minutes
		minutes = self.time / 60
		seconds = self.time % 60

		if seconds < 10
			seconds = "0" + seconds.to_s
		end

		t = minutes.to_s + ":" + seconds.to_s
		return t
	end

	def player_full_name
		if !self.player_id.nil?
			player = Player.find_by(cwhl_id: self.player_id)
			return player.full_name
		else
			player = Player.find_by(cwhl_id: self.serving_player_id)
			return player.nil? ? "Team Penalty" : "Team Penalty (served by #{player.full_name})"
		end
	end

	def team_abbreviation
		team = TeamStatline.find_by(team_code: self.team_id, season_id: self.season_id)
		abbreviation = !team.nil? ? team.abbreviation : "N/A"
		return abbreviation
	end

	def self.to_csv
		CSV.generate do |csv|
			column_names.delete("created_at")
			column_names.delete("updated_at")
			csv << column_names
			all.each do |penalty|
				csv << penalty.attributes.values_at(*column_names)
			end
		end
	end

end
