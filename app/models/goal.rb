class Goal < ApplicationRecord
	validates :game_id, uniqueness: { scope: [:period, :time] }
	has_many :on_ice_skaters, dependent: :destroy

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

	def situation
		if self.is_powerplay == true
			return "PP"
		elsif self.is_shorthanded == true
			return "SH"
		else
			return "EV"
		end
	end

	def description
		goal = Skater.find_by(player_id: self.goalscorer_id)
		a1 = Skater.find_by(player_id: self.a1_id)
		a2 = Skater.find_by(player_id: self.a2_id)

		if a1 == nil
			return goal.full_name
		elsif a2 == nil
			return goal.full_name + " (#{a1.full_name})"
		else
			return goal.full_name + " (#{a1.full_name}, #{a2.full_name})"
		end
	end

	def scoring_team
		TeamStatline.find_by(team_code: self.team_id, season_id: self.season_id).abbreviation
	end

	def scoring_team_players
		return OnIceSkater.where(goal_id: self.id, game_id: self.game_id, team_id: self.team_id)
	end

	def opposing_team_players
		return OnIceSkater.where(goal_id: self.id, game_id: self.game_id, team_id: self.opposing_team_id)
	end

	def home_on_ice
		game = Game.find_by(cwhl_game_id: self.game_id)
		ois = OnIceSkater.where(goal_id: self.id, team_id: game.home_team_id)
		skaters = []
		ois.each do |s|
			skater = PlayerGameStatline.find_by(player_id:s.player_id, game_id: game.cwhl_game_id)
			skaters << skater.number if !skater.nil? 
		end

		return skaters.map(&:inspect).join(', ')
	end

	def visitor_on_ice
		game = Game.find_by(cwhl_game_id: self.game_id)
		ois = OnIceSkater.where(goal_id: self.id, team_id: game.visiting_team_id)
		skaters = []
		ois.each do |s|
			skaters << Skater.find_by(player_id:s.player_id).number
		end

		return skaters.map(&:inspect).join(', ')
	end
end
