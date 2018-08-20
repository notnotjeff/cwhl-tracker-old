class Team < ApplicationRecord
	validates_uniqueness_of :name, scope: [:abbreviation, :city, :team_code]
	has_many :seasons, 	foreign_key: :team_id,
											primary_key: :id,
											class_name: 'TeamStatline'

	def full_name
		name = self.city + " " + self.name
		return name
	end

	def seasons_for_option
		options = []
		TeamStatline.where(team_code: self.team_code).each do |t|
			options << [t.season_abbreviation, t.season_id]
		end
		return options
	end

	def self.team_finder(searched)
		searched ||= ""
		terms = ""
		counter = 1

		if searched != ""
			searched.split(' ').each do |term|
				t = '%' + term.gsub("'", "''").gsub(/\d+/, '') + '%'
				if counter == 1
      		terms += "city ILIKE '#{t}' OR name ILIKE '#{t}'"
      	else
      		terms += " OR city ILIKE '#{t}' OR name ILIKE '#{t}'"
      	end
      	counter += 1
      	if counter > 10
      		break
      	end
    	end

      where(terms)
		else
			where("city != ?", "")
		end
	end

	def self.team_names_for_option
		teams = []
		all_teams = self.all.order(city: :asc)

		all_teams.each do |team|
			teams << ["#{team.abbreviation} - #{team.name}", team.id]
		end
		return teams
	end

	def self.update_teams(created_games, scrape_start_time)
		teams = []

		# Get Team ID's With Season ID's To Isolate What To Update
		created_games.each do |game|
			teams << [game.home_team_id, game.season_id]
			teams << [game.visiting_team_id, game.season_id]
		end

		# Remove Duplicates
		teams.uniq!

		# Each Team That Played Update Their Season Stats
		teams.each do |team_code, season_id|
			team = TeamStatline.find_by(team_code: team_code, season_id: season_id)
			home_games = Game.where(home_team_id: team_code, season_id: season_id)
			visiting_games = Game.where(visiting_team_id: team_code, season_id: season_id)
			shootout_attempts = ShootoutAttempt.where(team_id: team_code, season_id: season_id)
			TeamStatline.update_on_ice_results(team)

			team_stats = { games_played: 0,
										wins: 0,
										ot_wins: 0,
										so_wins: 0,
										forfeit_wins: 0,
										losses: 0,
										ot_losses: 0,
										so_losses: 0,
										forfeit_losses: 0,
										points: 0,
										points_percentage: 0,
										penalty_minutes: 0,
										row: 0,
										goals_for: 0,
										goals_against: 0,
										ev_goals_for: 0,
										ev_goals_against: 0,
										pp_goals_for: 0,
										pp_goals_against: 0,
										sh_goals_for: 0,
										sh_goals_against: 0,
										shots: 0,
										shots_against: 0,
										first_period_shots: 0,
										second_period_shots: 0,
										third_period_shots: 0,
										ot_shots: 0,
										ot_periods: 0,
										first_period_goals: 0,
										second_period_goals: 0,
										third_period_goals: 0,
										ot_goals: 0,
										shootout_attempts: 0,
										shootout_goals: 0,
										minors: 0,
										double_minors: 0,
										majors: 0,
										fights: 0,
										misconducts: 0,
										game_misconducts: 0 }

			home_games.each do |game|
				team_stats[:shots] += game.home_total_shots
				team_stats[:shots_against] += game.visitor_total_shots
				team_stats[:first_period_shots] += game.first_period_home_shots
				team_stats[:second_period_shots] += game.second_period_home_shots
				team_stats[:third_period_shots] += game.third_period_home_shots

				team_stats[:first_period_goals] += game.first_period_home_goals
				team_stats[:second_period_goals] += game.second_period_home_goals
				team_stats[:third_period_goals] += game.third_period_home_goals

				if game.overtime == true
					overtimes = Overtime.where(cwhl_game_id: game.cwhl_game_id, season_id: game.season_id)
					overtimes.each do |ot|
						team_stats[:ot_shots] += ot.home_shots
						team_stats[:ot_goals] += ot.home_goals
						team_stats[:ot_periods] += 1
					end
				end

				if game.winning_team_id.to_i == game.home_team_id.to_i && game.is_forfeit == true
					team_stats[:forfeit_wins] += 1
				elsif game.winning_team_id.to_i == game.home_team_id.to_i && game.overtime == false && game.shootout == false
					team_stats[:wins] += 1
				elsif game.winning_team_id.to_i == game.home_team_id.to_i && game.overtime == true && game.shootout == false
					team_stats[:ot_wins] += 1
				elsif game.winning_team_id.to_i == game.home_team_id.to_i && game.shootout == true
					team_stats[:so_wins] += 1
				elsif game.winning_team_id.to_i != game.home_team_id.to_i && game.is_forfeit == true
					team_stats[:forfeit_losses] += 1
				elsif game.winning_team_id.to_i != game.home_team_id.to_i && game.overtime == false && game.shootout == false
					team_stats[:losses] += 1
				elsif game.winning_team_id.to_i != game.home_team_id.to_i && game.overtime == true && game.shootout == false
					team_stats[:ot_losses] += 1
				elsif game.winning_team_id.to_i != game.home_team_id.to_i && game.shootout == true
					team_stats[:so_losses] += 1
				end
			end

			visiting_games.each do |game|
				team_stats[:shots] += game.visitor_total_shots
				team_stats[:shots_against] += game.home_total_shots
				team_stats[:first_period_shots] += game.first_period_visitor_shots
				team_stats[:second_period_shots] += game.second_period_visitor_shots
				team_stats[:third_period_shots] += game.third_period_visitor_shots

				team_stats[:first_period_goals] += game.first_period_visitor_goals
				team_stats[:second_period_goals] += game.second_period_visitor_goals
				team_stats[:third_period_goals] += game.third_period_visitor_goals

				if game.overtime == true
					overtimes = Overtime.where(cwhl_game_id: game.cwhl_game_id, season_id: game.season_id)
					overtimes.each do |ot|
						team_stats[:ot_shots] += ot.visitor_shots
						team_stats[:ot_goals] += ot.visitor_goals
						team_stats[:ot_periods] += 1
					end
				end

				if game.winning_team_id.to_i == game.visiting_team_id.to_i && game.is_forfeit == true
					team_stats[:forfeit_wins] += 1
				elsif game.winning_team_id.to_i == game.visiting_team_id.to_i && game.overtime == false && game.shootout == false
					team_stats[:wins] += 1
				elsif game.winning_team_id.to_i == game.visiting_team_id.to_i && game.overtime == true && game.shootout == false
					team_stats[:ot_wins] += 1
				elsif game.winning_team_id.to_i == game.visiting_team_id.to_i && game.shootout == true
					team_stats[:so_wins] += 1
				elsif game.winning_team_id.to_i != game.visiting_team_id.to_i && game.is_forfeit == true
					team_stats[:forfeit_losses] += 1
				elsif game.winning_team_id.to_i != game.visiting_team_id.to_i && game.overtime == false && game.shootout == false
					team_stats[:losses] += 1
				elsif game.winning_team_id.to_i != game.visiting_team_id.to_i && game.overtime == true && game.shootout == false
					team_stats[:ot_losses] += 1
				elsif game.winning_team_id.to_i != game.visiting_team_id.to_i && game.shootout == true
					team_stats[:so_losses] += 1
				end
			end

			shootout_attempts.each do |a|
				team_stats[:shootout_goals] += 1 if a.scored == true
			end

			points = (team_stats[:wins].to_i * 2) + (team_stats[:ot_wins].to_i * 2) + (team_stats[:so_wins].to_i * 2) + (team_stats[:ot_losses].to_i) + (team_stats[:so_losses].to_i) + (team_stats[:forfeit_wins].to_i * 2)
			goals_for = Goal.where(team_id: team_code, season_id: season_id).count
			goals_against = Goal.where(opposing_team_id: team_code, season_id: season_id).count
			ev_goals_for = Goal.where(team_id: team_code, is_powerplay: false, is_shorthanded: false, is_penalty_shot: false, season_id: season_id).count
			ev_goals_against = Goal.where(opposing_team_id: team_code, is_powerplay: false, is_shorthanded: false, is_penalty_shot: false, season_id: season_id).count
			pp_goals_for = Goal.where(team_id: team_code, is_powerplay: true, season_id: season_id).count
			pp_goals_against = Goal.where(opposing_team_id: team_code, is_powerplay: true, season_id: season_id).count
			sh_goals_for = Goal.where(team_id: team_code, is_shorthanded: true, season_id: season_id).count
			sh_goals_against = Goal.where(opposing_team_id: team_code, is_shorthanded: true, season_id: season_id).count
			games_played = home_games.count + visiting_games.count
			unforfeited_games_played = games_played - team_stats[:forfeit_losses] - team_stats[:forfeit_wins]
			home_ot_games_played = Game.where(home_team_id: team_code, overtime: true, season_id: season_id).count
			visiting_ot_games_played = Game.where(visiting_team_id: team_code, overtime: true, season_id: season_id).count

			if games_played.to_i > 0
				points_percentage = BigDecimal.new(points) / BigDecimal.new(games_played.to_i * 2)
			else
				points_percentage = 0
			end

			penalties = Penalty.where(team_id: team_code.to_i, season_id: season_id)

			penalties.each do |penalty|
				team_stats[:penalty_minutes] += penalty.duration_in_minutes.to_i
			end

			team_stats[:minors] = penalties.where(is_minor: true).count
			team_stats[:double_minors] = penalties.where(is_double_minor: true).count
			team_stats[:majors] = penalties.where(is_major: true).count
			team_stats[:fights] = penalties.where(is_fight: true).count
			team_stats[:misconducts] = penalties.where(is_misconduct: true).count
			team_stats[:game_misconducts] = penalties.where(is_game_misconduct: true).count

			team_save_percentage = 1 - (BigDecimal.new(goals_against) / BigDecimal.new(team_stats[:shots_against]))
			team_shooting_percentage = BigDecimal.new(goals_for) / BigDecimal.new(team_stats[:shots])

		
			team.update_attributes( games_played: games_played,
									unforfeited_games_played: unforfeited_games_played,
									wins: team_stats[:wins].to_i,
									row: team_stats[:wins] + team_stats[:ot_wins],
									losses: team_stats[:losses],
									forfeit_wins: team_stats[:forfeit_wins],
									so_wins: team_stats[:so_wins],
									ot_wins: team_stats[:ot_wins],
									so_losses: team_stats[:so_losses],
									ot_losses: team_stats[:ot_losses],
									forfeit_losses: team_stats[:forfeit_losses],
									ot_periods: team_stats[:ot_periods],
									points: points,
									points_percentage: points_percentage,
									penalty_minutes: team_stats[:penalty_minutes],
									minors: team_stats[:minors],
									double_minors: team_stats[:double_minors],
									majors: team_stats[:majors],
									fights: team_stats[:fights],
									misconducts: team_stats[:misconducts],
									game_misconducts: team_stats[:game_misconducts],
									minors_pg: (BigDecimal.new(team_stats[:minors]) / BigDecimal.new(unforfeited_games_played)),
									double_minors_pg: (BigDecimal.new(team_stats[:double_minors]) / BigDecimal.new(unforfeited_games_played)),
									majors_pg: (BigDecimal.new(team_stats[:majors]) / BigDecimal.new(unforfeited_games_played)),
									fights_pg: (BigDecimal.new(team_stats[:fights]) / BigDecimal.new(unforfeited_games_played)),
									misconducts_pg: (BigDecimal.new(team_stats[:misconducts]) / BigDecimal.new(unforfeited_games_played)),
									game_misconducts_pg: (BigDecimal.new(team_stats[:game_misconducts]) / BigDecimal.new(unforfeited_games_played)),
									shots: team_stats[:shots],
									shots_against: team_stats[:shots_against],
									shooting_percent: team_shooting_percentage * 100,
									save_percent: team_save_percentage * 100,
									first_period_shots: team_stats[:first_period_shots],
									second_period_shots: team_stats[:second_period_shots],
									third_period_shots: team_stats[:third_period_shots],
									ot_shots: team_stats[:ot_shots],
									first_period_goals: team_stats[:first_period_goals],
									second_period_goals: team_stats[:second_period_goals],
									third_period_goals: team_stats[:third_period_goals],
									ot_period_goals: team_stats[:ot_goals],
									first_period_shots_pg: BigDecimal.new(team_stats[:first_period_shots]) / BigDecimal.new(unforfeited_games_played),
									second_period_shots_pg: BigDecimal.new(team_stats[:second_period_shots]) / BigDecimal.new(unforfeited_games_played),
									third_period_shots_pg: BigDecimal.new(team_stats[:third_period_shots]) / BigDecimal.new(unforfeited_games_played),
									ot_period_shots_pg: BigDecimal.new(team_stats[:ot_shots]) / BigDecimal.new(home_ot_games_played + visiting_ot_games_played),
									first_period_goals_pg: BigDecimal.new(team_stats[:first_period_goals]) / BigDecimal.new(unforfeited_games_played),
									second_period_goals_pg: BigDecimal.new(team_stats[:second_period_goals]) / BigDecimal.new(unforfeited_games_played),
									third_period_goals_pg: BigDecimal.new(team_stats[:third_period_goals]) / BigDecimal.new(unforfeited_games_played),
									ot_period_goals_pg: BigDecimal.new(team_stats[:ot_goals]) / BigDecimal.new(home_ot_games_played + visiting_ot_games_played),
									goals_for: goals_for,
									goals_against: goals_against,
									ev_goals_for: ev_goals_for,
									ev_goals_against: ev_goals_against,
									pp_goals_for: pp_goals_for,
									pp_goals_against: pp_goals_against,
									sh_goals_for: sh_goals_for,
									sh_goals_against: sh_goals_against,
									goals_for_pg: BigDecimal.new(goals_for) / BigDecimal.new(unforfeited_games_played),
									goals_against_pg: BigDecimal.new(goals_against) / BigDecimal.new(unforfeited_games_played),
									goals_percent: (BigDecimal.new(goals_for) / (BigDecimal.new(goals_for) + BigDecimal.new(goals_against))) * 100,
									ev_goals_for_pg: BigDecimal.new(ev_goals_for) / BigDecimal.new(unforfeited_games_played),
									ev_goals_against_pg: BigDecimal.new(ev_goals_against) / BigDecimal.new(unforfeited_games_played),
									ev_goals_percent: (BigDecimal.new(ev_goals_for) / (BigDecimal.new(ev_goals_for) + BigDecimal.new(ev_goals_against))) * 100,
									pp_goals_for_pg: BigDecimal.new(pp_goals_for) / BigDecimal.new(unforfeited_games_played),
									pp_goals_against_pg: BigDecimal.new(pp_goals_against) / BigDecimal.new(unforfeited_games_played),
									sh_goals_for_pg: BigDecimal.new(sh_goals_for) / BigDecimal.new(unforfeited_games_played),
									sh_goals_against_pg: BigDecimal.new(sh_goals_against) / BigDecimal.new(unforfeited_games_played),
									shots_pg: BigDecimal.new(team_stats[:shots]) / BigDecimal.new(unforfeited_games_played),
									shots_against_pg: BigDecimal.new(team_stats[:shots_against]) / BigDecimal.new(unforfeited_games_played),
									shots_percent: BigDecimal.new(team_stats[:shots]) / BigDecimal.new(team_stats[:shots] + team_stats[:shots_against]),
									shootout_attempts: shootout_attempts.count,
									shootout_goals: team_stats[:shootout_goals],
									shootout_percent: BigDecimal.new(team_stats[:shootout_goals]) / BigDecimal.new(shootout_attempts.count),
									pdo: 	(team_shooting_percentage + team_save_percentage) * 100 )
		end
	end

	private
		def create_logo_url
			safe_name = self.name.tr(" ", "_").downcase
			safe_abb = self.abbreviation.downcase
			self.logo_url = "#{self.team_code}_#{safe_abb}_#{safe_name}.png"
		end
end
