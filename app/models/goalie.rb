class Goalie < ApplicationRecord
	validates :player_id, uniqueness: { scope: [:season_id, :team_id] }
	has_many :goalie_game_statlines, 	->(goalie) { where(season_id: goalie.season_id) },
																		foreign_key: :player_id,
																		primary_key: :player_id,
																		dependent: :destroy
	belongs_to :player, 	primary_key: :cwhl_id,
												foreign_key: :player_id,
												optional: true
	belongs_to :team_statline,	->(goalie) { where(season_id: goalie.season_id) },
															foreign_key: :team_id,
															primary_key: :team_code
	paginates_per 50

	def self.to_csv
		CSV.generate do |csv|
			column_names.delete("created_at")
			column_names.delete("updated_at")
			csv << column_names
			all.each do |goalie|
				csv << goalie.attributes.values_at(*column_names)
			end
		end
	end

	def token_name
		return "#{self.first_name.upcase}.#{self.last_name.upcase}"
	end

	def self.tokens_for_option
		goalies = []
		self.all.select(:first_name, :last_name, :player_id).distinct(:player_id).order(last_name: :asc).each do |s|
			goalies << [s.token_name, s.player_id]
		end

		return goalies
	end

	def player_profile
		Player.find_by(cwhl_id: player_id)
	end

	def team_profile_id
		t = TeamStatline.find_by(team_code: self.team_id, season_id: self.season_id)
		Team.find_by(city: t.city, name: t.name, abbreviation: t.abbreviation, team_code: t.team_code).id
	end

	def self.situation_options
		["Regulation", "Shootout/Penalty Shot"]
	end

	def full_name
		return self.first_name + " " + self.last_name
	end

	def season
		Season.find_by(cwhl_id:self.season_id).abbreviation
	end

	def is_rookie_star
		if self.is_rookie == true
			return "*"
		else
			return ""
		end
	end

	def self.name_finder(searched)
		searched ||= ""
		terms = ""
		counter = 1

		if searched != ""
			searched.split(' ').each do |term|
				t = '%' + term.gsub(/\d+/, '') + '%'
				if counter == 1
      		terms += "first_name ILIKE '#{t}' OR last_name ILIKE '#{t}'"
      	else
      		terms += " OR first_name ILIKE '#{t}' OR last_name ILIKE '#{t}'"
      	end
      	counter += 1
      	if counter > 10
      		break
      	end
    	end

      where(terms)
		else
			where("first_name != ?", "")
		end
	end

	def self.goalie_select(goalies)
		return all if goalies.count <= 0
		goalies.map(&:to_i)

		where(player_id: goalies)
	end

	def self.rookie_select(rookie)
		if rookie == true
			where("is_rookie = ?", true)
		else
			where("is_rookie = ? OR is_rookie = ? OR is_rookie IS NULL", true, false)
		end
	end

	def self.minimum_games(games)
		games ||= 0
		where("games_played >= ?", games)
	end

	def self.minimum_shots_against(shots)
		shots ||= 0
		where("shots_against >= ?", shots)
	end

	def self.age_range_select(low, high)
		where("season_age >= ? AND season_age <= ?", low.to_i, high.to_i)
	end

	def self.teams_select(teams)
		return all if teams.nil?
		where(team_id: teams.map {|t| t[1]}, team_abbreviation: teams.map {|t| t[0]})
	end

	def shootout_percent_as_percent
		(self.shootout_percent * 100).to_s + "%"
	end

	def self.season_select(year_start, year_end, is_regular, is_playoffs)
		if is_regular == false || is_playoffs == false
			season_ids = Season.where('year_start >= ? AND year_end <= ? AND is_regular_season = ? AND is_playoffs = ?', year_start, year_end, is_regular, is_playoffs).pluck(:cwhl_id)
		else
			season_ids = Season.where('year_start >= ? AND year_end <= ? AND year_end != ?', year_start, year_end, year_start).pluck(:cwhl_id)
		end
		return where(season_id: season_ids)
	end

	def self.set_season_ages
		seasons = self.where(season_age: nil).or(self.where(season_age: 0))

		seasons.each do |season|
			profile = Player.find(season.player_id)
			next if profile.birthdate == nil
			season_profile = Season.find_by(cwhl_id: season.season_id)
			season_age = get_age_at_date(season_profile.start_date, profile.birthdate)
			season.update_attributes(season_age: season_age)
		end
	end

	def self.aggregate_and_minimum_games(aggregation_type, minimum_games)
		if aggregation_type == 1
			season_statement = " MAX(season_age) AS season_age,"
			group_statement = 'player_id'
		elsif aggregation_type == 2
			season_statement = " season_age, MIN(season_abbreviation) AS season_abbreviation,"
			group_statement = 'player_id, season_age'
		else
			return all.where('games_played >= ?', minimum_games)
		end

		aggregation_string = "player_id,
								#{season_statement}
								BOOL_OR(is_rookie) AS is_rookie,
								STRING_AGG(DISTINCT(goalies.full_name), '/') AS full_name,
								MAX(last_name) AS last_name,
								MAX(first_name) AS first_name,
								MIN(dob) AS dob,
								MAX(team_id) AS team_id,
								STRING_AGG(DISTINCT(goalies.team_abbreviation), '/') AS team_abbreviation,
								MAX(season_age) AS season_age,
								STRING_AGG(DISTINCT(goalies.position), '/') AS position,
								SUM(games_played) AS games_played,
								SUM(goals_against) AS goals_against,
								SUM(shots_against) AS shots_against,
								SUM(saves) AS saves,
								ROUND(CAST(SUM(goals_against) AS DECIMAL) / CASE SUM(time_on_ice) WHEN 0 THEN NULL ELSE CAST(SUM(time_on_ice) AS DECIMAL) / 60 / 60 END, 2) AS goals_against_average,
								ROUND(CAST(SUM(saves) AS DECIMAL) / (CASE SUM(shots_against) WHEN 0 THEN NULL ELSE SUM(shots_against) END), 3) AS save_percentage,
								ROUND(CAST(SUM(shots_against) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS shots_against_pg,
								ROUND(CAST(SUM(saves) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS saves_pg,
								SUM(goals) AS goals,
								SUM(assists) AS assists,
								SUM(points) AS points,
								SUM(penalties) AS penalties,
								SUM(penalty_minutes) AS penalty_minutes,
								SUM(penalty_shot_attempts) AS penalty_shot_attempts,
								SUM(penalty_shot_goals_against) AS penalty_shot_goals_against,
								SUM(shootout_attempts) AS shootout_attempts,
								SUM(shootout_goals_against) AS shootout_goals_against,
								ROUND((CAST((SUM(shootout_attempts) - SUM(shootout_goals_against)) AS DECIMAL) / CASE SUM(shootout_attempts) WHEN 0 THEN NULL ELSE SUM(shootout_attempts) END) * 100, 2) AS shootout_percent"

		group(group_statement).select(aggregation_string).having("SUM(games_played) >= ?", minimum_games)
	end

	def self.update_goalies(created_games, scrape_start_time)
		goalies = []

		# Get Team ID's With Season ID's To Isolate What To Update
		created_games.each do |game|
			game.goalies.each do |goalie|
				goalies << [goalie.player_id, goalie.team_id, game.season_id]
			end
		end

		goalies.each do |goalie_id, team_id, season_id|
			Goalie.update_goalie(goalie_id, team_id, season_id)
		end
	end

	def self.update_goalie(goalie_id, team_id, season_id)
		goalie = Goalie.find_by(player_id: goalie_id, team_id: team_id, season_id: season_id)

		goalie_stats = {  goals_against: 0,
											shots_against: 0,
											saves: 0,
											time_on_ice: 0,
											goals: 0,
											assists: 0,
											points: 0,
											penalties: 0,
											penalty_minutes: 0,
											games_played: 0,
											starts: 0,
											penalty_shot_goals_against: 0,
											penalty_shot_attempts_against: 0,
											shootout_goals_against: 0,
											shootout_attempts: 0 }

		games = GoalieGameStatline.where(player_id: goalie.player_id, team_id: goalie.team_id, season_id: goalie.season_id)
		penalties = Penalty.where(player_id: goalie.player_id, team_id: goalie.team_id, season_id: goalie.season_id)
		goalie_stats[:penalty_shot_goals_against] = PenaltyShot.where(goalie_id: goalie.player_id, defending_team_id: goalie.team_id, scored: true, season_id: goalie.season_id).count
		goalie_stats[:penalties] = penalties.count
		goalie_stats[:penalty_shot_attempts_against] = PenaltyShot.where(goalie_id: goalie.player_id, defending_team_id: goalie.team_id, season_id: goalie.season_id).count
		goalie_stats[:shootout_attempts] = ShootoutAttempt.where(goalie_id: goalie.player_id, defending_team_id: goalie.team_id, season_id: goalie.season_id).count
		goalie_stats[:shootout_goals_against] = ShootoutAttempt.where(goalie_id: goalie.player_id, defending_team_id: goalie.team_id, scored: true, season_id: goalie.season_id).count

		penalties.each do |penalty|
			goalie_stats[:penalty_minutes] += penalty.duration_in_minutes.to_i
		end

		games.each do |game|
			goalie_stats[:goals_against] += game.goals_against
			goalie_stats[:shots_against] += game.shots_against
			goalie_stats[:saves] += game.saves
			goalie_stats[:time_on_ice] += game.time_on_ice
			goalie_stats[:goals] += game.goals
			goalie_stats[:assists] += game.assists
			goalie_stats[:points] += game.points
			goalie_stats[:starts] += 1 if game.starting == true || game.time_on_ice > 0
		end

		time_on_ice_in_gp = (BigDecimal.new(goalie_stats[:time_on_ice]) / 60) / 60  # Convert seconds into minutes, then divide minutes into games played
		goals_against_average = BigDecimal.new(goalie_stats[:goals_against]) / BigDecimal.new(time_on_ice_in_gp)
		shots_against_pg = BigDecimal.new(goalie_stats[:shots_against]) / BigDecimal.new(time_on_ice_in_gp)
		saves_pg = BigDecimal.new(goalie_stats[:saves]) / BigDecimal.new(time_on_ice_in_gp)

		goalie.update_attributes( goals_against: goalie_stats[:goals_against],
															shots_against: goalie_stats[:shots_against],
															saves: goalie_stats[:saves],
															time_on_ice: goalie_stats[:time_on_ice],
															games_played: goalie_stats[:starts],
															goals: goalie_stats[:goals],
															assists: goalie_stats[:assists],
															points: goalie_stats[:points],
															penalties: goalie_stats[:penalties],
															penalty_minutes: goalie_stats[:penalty_minutes],
															penalty_shot_goals_against: goalie_stats[:penalty_shot_goals_against],
															penalty_shot_attempts: goalie_stats[:penalty_shot_attempts_against],
															shootout_goals_against: goalie_stats[:shootout_goals_against],
															shootout_attempts: goalie_stats[:shootout_attempts],
															# RATE STATS
															goals_against_average: goals_against_average,
															shots_against_pg: shots_against_pg,
															save_percentage: BigDecimal.new(1) - (BigDecimal.new(goalie_stats[:goals_against]) / BigDecimal.new(goalie_stats[:shots_against])),
															shootout_percent: BigDecimal.new(1) - (BigDecimal.new(goalie_stats[:shootout_goals_against]) / BigDecimal.new(goalie_stats[:shootout_attempts])),
															saves_pg: saves_pg
														)
	end

	private
		def self.get_age_at_date(date, birthdate)
			BigDecimal.new((date - birthdate).to_i) / BigDecimal.new(365)
		end
end
