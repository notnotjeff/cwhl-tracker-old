class Game < ApplicationRecord
	require 'open-uri'

	paginates_per 50
	validates_uniqueness_of :cwhl_game_id

	has_many :skaters,	foreign_key: :game_id,
											primary_key: :cwhl_game_id,
											class_name: 'PlayerGameStatline',
											dependent: :destroy
	has_many :goalies,	foreign_key: :game_id,
											primary_key: :cwhl_game_id,
											class_name: 'GoalieGameStatline',
											dependent: :destroy
	has_many :goals, foreign_key: :game_id,
									 primary_key: :cwhl_game_id,
									 dependent: :destroy
	has_many :shootout_attempts, foreign_key: :game_id,
															 primary_key: :cwhl_game_id,
															 dependent: :destroy
	has_many :penalty_shots, foreign_key: :game_id,
													 primary_key: :cwhl_game_id,
													 dependent: :destroy
	has_many :on_ice_skaters, foreign_key: :game_id,
														 primary_key: :cwhl_game_id,
													 dependent: :destroy
	has_many :penalties, foreign_key: :game_id,
									 		 primary_key: :cwhl_game_id,
											 dependent: :destroy
	has_many :coaches, foreign_key: :game_id,
									 		primary_key: :cwhl_game_id,
											dependent: :destroy
	has_many :referees, foreign_key: :game_id,
									 		primary_key: :cwhl_game_id,
											dependent: :destroy
	has_many :stars, foreign_key: :game_id,
							 		 primary_key: :cwhl_game_id,
									 dependent: :destroy
	has_many :overtimes, foreign_key: :cwhl_game_id,
									 		 primary_key: :cwhl_game_id,
											 dependent: :destroy
	has_many :teams, foreign_key: :game_id,
							 		 primary_key: :cwhl_game_id,
									 class_name: 'TeamGameStatline',
									 dependent: :destroy
	belongs_to :season, primary_key: :cwhl_id,
											foreign_key: :season_id,
											optional: true

	def game_abbreviation
		return "#{visitor_abbreviation} @ #{home_abbreviation}"
	end

	def home_name
		name = Team.find_by(team_code: self.home_team_id).full_name
	end

	def visitor_name
		name = Team.find_by(team_code: self.visiting_team_id).full_name
	end

	def home_total_shots
		ot_shots = 0
		if self.overtimes.count > 0
			self.overtimes.each do |ot|
				ot_shots += ot.home_shots
			end
		end

		return self.home_shots + ot_shots
	end

	def visitor_total_shots
		ot_shots = 0
		if self.overtimes.count > 0
			self.overtimes.each do |ot|
				ot_shots += ot.visitor_shots
			end
		end

		return self.visitor_shots + ot_shots
	end

	def ended_in
		if self.overtime == true && self.shootout == true
			return "SO"
		elsif self.overtime == true && self.shootout != true
			return "OT"
		else
			return ""
		end
	end

	def self.results_for_option
		results = ["Any", "Regulation", "Overtime", "Shootout", "OT & SO"]
	end

	def self.team_select(team_profile_id)
		team = Team.find_by(id: team_profile_id)
		if team
			where("home_team_id = ? OR visiting_team_id = ?", team.team_code, team.team_code)
		else
			where("id >= ?", 0)
		end
	end

	def self.ids_for_option
		game_ids = self.all.order(cwhl_game_id: :asc).pluck(:cwhl_game_id).map(&:to_i)
		return game_ids
	end

	def self.game_ids_select(game_ids)
		return all if game_ids.nil?
		where(cwhl_game_id: game_ids)
	end

	def self.season_select(seasons)
		return all if seasons.include?(0)
		where(season_id: seasons)
	end

	def self.teams_select(teams, only_selected)
		return all if teams.nil?

		if only_selected != false
			where(home_team_id: teams.map {|t| t[1]}, visiting_team_id: teams.map {|t| t[1]}, home_abbreviation: teams.map {|t| t[0]}, visitor_abbreviation: teams.map {|t| t[0]})
		else
			where(home_team_id: teams.map {|t| t[1]}, home_abbreviation: teams.map {|t| t[0]}).or(where(visiting_team_id: teams.map {|t| t[1]}, visitor_abbreviation: teams.map {|t| t[0]}))
		end
	end

	def self.with_result(result)
    if result == "Overtime"
      where('overtime = ? AND shootout = ?', true, false)
    elsif result == "OT & SO"
     	where('overtime = ? OR shootout = ?', true, true)
    elsif result == "Shootout"
      where('shootout = ?', true)
    elsif result == "Regulation"
      where('overtime = ? AND shootout = ?', false, false)
    else
      where('cwhl_game_id > ?', 0)
    end
  end

  def self.total_goals_scored(gs)
  	where('goals_count >= ?', gs)
  end

	def home_overtime_shots_goals
		goals = 0
		shots = 0
		self.overtimes.each do |ot|
			shots += ot.home_shots.to_i
			goals += ot.home_goals.to_i
		end
		return shots, goals
	end

	def visitor_overtime_shots_goals
		goals = 0
		shots = 0
		self.overtimes.each do |ot|
			shots += ot.visitor_shots.to_i
			goals += ot.visitor_goals.to_i
		end
		return shots, goals
	end

	def self.scrape_range_of_games(start_date, end_date)
		time = Time.now
		dates = []

		# Make Sure Date Exists
		return puts "Invalid date inputted" unless start_date.is_a?(Date) && end_date.is_a?(Date)

		# If games have yet to be played don't scrape
		return puts "Please scrape this date at a later time once all games are garunteed to be over" if start_date.today? || end_date.today?

		# Separate Each Day In Range Into Array
		(start_date..end_date).each do |date|
			dates << date
		end

		# Cycle Through Each Date And Scrape Game
		dates.each do |date|
			scrape_day_of_games(date)
		end

		# Update Player Statistics If They Played A Game And Get Player Bio If New To Database
		merge_games(time)
		Player.scrape_ages()
		Player.scrape_rookies()
	end

	def self.scraper_test(game)
		feed_url = "https://lscluster.hockeytech.com/feed/index.php?feed=statviewfeed&view=gameSummary&game_id=#{game}&key=eb62889ab4dfb04e&site_id=2&client_code=cwhl&lang=en&league_id=&callback=angular.callbacks._2"

		# Scrape Game
		game_file = game_scraper(feed_url)
		return game_file
	end

	private
		#
		# MAIN SCRAPER FUNCTIONS
		#

		def self.scrape_day_of_games(date)
			# Make Sure Date Exists
			return puts "Invalid date inputted" unless date.is_a?(Date)
			
			# Convert Date Into Format For Scraper
			month = date.strftime("%m")
			date_string = date.strftime("%a, %b %-d")
			
			# Get Season ID, If It Doesn't Exist Throw Error
			season_search = Season.where('start_date <= ? AND end_date >= ? AND is_allstar_game = ? AND is_exhibition = ?', date, date, false, false)
			if season_search.count > 0
				season_id = season_search.first.cwhl_id
			else
				Season.scrape_all_seasons
			end
			
			month_url = "https://lscluster.hockeytech.com/feed/index.php?feed=statviewfeed&view=schedule&team=-1&season=#{season_id}&month=#{month}&location=homeaway&key=eb62889ab4dfb04e&client_code=cwhl&site_id=2&league_id=1&division_id=-1&lang=en&callback=angular.callbacks._1"

			games = Game.get_game_urls(month_url, date_string)

			games.each do |game|
				Game.scrape_game(game)
			end
		end

		def self.scrape_game(game)
			feed_url = "https://lscluster.hockeytech.com/feed/index.php?feed=statviewfeed&view=gameSummary&game_id=#{game}&key=eb62889ab4dfb04e&site_id=2&client_code=cwhl&lang=en&league_id=&callback=angular.callbacks._2"

			
			if ![396, 603, 604, 413, 425].include? game.to_i  # IDs of empty games that should be skipped if trying to scrape
				# Scrape Game
				game_file = game_scraper(feed_url)
			else
				game_file = false
			end

			# Add Game To DB
			add_game(game_file) unless game_file == false
		end

		#
		# SCRAPING HELPER FUNCTIONS
		#

		# Get Game IDs For All Games On A Specific Date
		def self.get_game_urls(url, date)
			all_games = JSON.parse(Nokogiri::HTML(open(url)).to_s[/\(\[(.*?)\]\)/].tr('(', '').tr(')', '')).first["sections"].first["data"]
			game_ids = []

			all_games.each do |game|
				game_ids << game["row"]["game_id"].to_i if game["row"]["date_with_day"] == date
			end
			
			return game_ids
		end

		def self.game_scraper(url)
		  doc = JSON.parse(Nokogiri::HTML(open(url)).to_s[/\(\{(.*?)\}\)/].tr('(', '').tr(')', ''))

			# If Game Is An Allstar Game Don't Scrape
			season_id = doc["details"]["seasonId"]
			Season.scrape_all_seasons if Season.find_by(cwhl_id: season_id)
			season = Season.find_by(cwhl_id: season_id)
		  	return false if season.nil? || season.is_allstar_game == true || season.is_exhibition == true

		  # Scrape Game Information
		  game_info = game_summary_scrape(doc)
		  
		  # Cut Out Each Team's Roster Information
		  home_team_scrape = doc["homeTeam"]
		  visiting_team_scrape = doc["visitingTeam"]
		  
		  # Input Each Team's Players, Coaches and Goalies Into Array To Be Added To DB
		  home_coaches, home_skaters, home_goalies, home_city, home_nickname, home_abb = team_scrape(home_team_scrape)
		  visiting_coaches, visiting_skaters, visiting_goalies, visiting_city, visiting_nickname, visiting_abb = team_scrape(visiting_team_scrape)

		  # Store All Period Data Into Array
		  period_data = doc["periods"]

		  # Scrape Periods Scoring/Penalties Into Hashes
		  game_scoring, game_penalties, game_statlines = boxscore_scrape(game_info[:home_team_id], game_info[:visiting_team_id], period_data)

		  # Get Shootout Stats If Game Goes To Shootout
		  if game_info[:shootout] == true
		  	shootout_data = doc["shootoutDetails"]
		  	home_shootout_data = doc["shootoutDetails"]["homeTeamShots"]
		  	visiting_shootout_data = doc["shootoutDetails"]["visitingTeamShots"]

		  	# Parse Shootout Data And Add It To Hash
		  	home_shootout_shots = scrape_shootout_attempts(home_shootout_data, game_info[:home_team_id], game_info[:visiting_team_id])
		  	visiting_shootout_shots = scrape_shootout_attempts(visiting_shootout_data, game_info[:visiting_team_id], game_info[:home_team_id])
		  end

		  # Get Penalty Shots
		  home_penalty_shot_data = doc["penaltyShots"]["homeTeam"]
		  visitor_penalty_shot_data = doc["penaltyShots"]["visitingTeam"]

		  home_penalty_shots = scrape_penalty_shots(home_penalty_shot_data, game_info[:home_team_id], game_info[:visiting_team_id])
		  visitor_penalty_shots = scrape_penalty_shots(visitor_penalty_shot_data, game_info[:visiting_team_id], game_info[:home_team_id])

		  # # Merge All Hashes Into Full Game Hash
		  game_info[:home_team_city] = home_city
		  game_info[:home_team_name] = home_nickname
		  game_info[:home_team_abbreviation] = home_abb
		  game_info[:visiting_team_city] = visiting_city
		  game_info[:visiting_team_name] = visiting_nickname
		  game_info[:visiting_team_abbreviation] = visiting_abb
		  game_info[:game_scoring] = game_scoring
		  game_info[:game_penalties] = game_penalties
		  game_info[:home_coaches] = home_coaches
		  game_info[:visiting_coaches] = visiting_coaches
		  game_info[:home_skaters] = home_skaters
		  game_info[:visiting_skaters] = visiting_skaters
		  game_info[:home_goalies] = home_goalies
		  game_info[:visiting_goalies] = visiting_goalies
		  game_info[:game_statlines] = game_statlines
		  game_info[:home_shootout_attempts] = home_shootout_shots
		  game_info[:visiting_shootout_attempts] = visiting_shootout_shots
		  game_info[:home_penalty_shots] = home_penalty_shots
		  game_info[:visitor_penalty_shots] = visitor_penalty_shots

		  return game_info
		end

		def self.game_summary_scrape(doc)
			# Initialize Variables
			gs = Hash.new
			gs[:status] = true
			
			game_summary = doc["details"]
			status = doc["details"]["status"]
			referees_data = doc["referees"]
			linesmen_data = doc["linesmen"]
			three_stars_data = doc["mostValuablePlayers"]
			penalty_shots_data = doc["penaltyShots"]
			home_team_id = doc["homeTeam"]["info"]["id"].to_i
			visiting_team_id = doc["visitingTeam"]["info"]["id"].to_i
			period_data = doc["periods"]
			periods = doc["periods"].count
			overtime = periods > 3 ? true : false
			shootout = doc["hasShootout"] == true ? true : false

			# Input Game Summary Stats Into Hash
			gs[:game_id] = doc["details"]["id"]
			gs[:game_date] = Date.parse(doc["details"]["date"])
			gs[:game_number] = doc["details"]["gameNumber"].to_i
			gs[:venue] = doc["details"]["venue"]
			gs[:attendance] = doc["details"]["attendance"].to_i
			gs[:start_time] = doc["details"]["startTime"]
			gs[:end_time]  = doc["details"]["endTime"]
			gs[:duration] = doc["details"]["duration"]
			gs[:season_id] = doc["details"]["seasonId"].to_i
			gs[:home_team_id] = home_team_id
			gs[:visiting_team_id] = visiting_team_id
			gs[:overtime] = overtime
			gs[:shootout] = shootout
			gs[:periods] = periods
			
			# If game was forfeitted then set hash values to empty arrays
			if !status[/Forfeit/].nil?
				gs[:winning_team_id] = status[/Home/].nil? ? home_team_id : visiting_team_id
				gs[:status] = false

				gs[:scoring_summary] ||= Hash.new
				gs[:scoring_summary][:home_team] ||= Hash.new
				gs[:scoring_summary][:visiting_team] ||= Hash.new
				gs[:scoring_summary][:home_team][:goals] ||= []
				gs[:scoring_summary][:visiting_team][:goals] ||= []
				gs[:scoring_summary][:home_team][:shots] ||= []
				gs[:scoring_summary][:visiting_team][:shots] ||= []

				gs[:scoring_summary][:home_team][:goals][0] = gs[:scoring_summary][:home_team][:goals][1] = gs[:scoring_summary][:home_team][:goals][2] = 0
				gs[:scoring_summary][:home_team][:shots][0] = gs[:scoring_summary][:home_team][:shots][1] = gs[:scoring_summary][:home_team][:shots][2] = 0
				gs[:scoring_summary][:visiting_team][:goals][0] = gs[:scoring_summary][:visiting_team][:goals][1] = gs[:scoring_summary][:visiting_team][:goals][2] = 0
				gs[:scoring_summary][:visiting_team][:shots][0] = gs[:scoring_summary][:visiting_team][:shots][1] = gs[:scoring_summary][:visiting_team][:shots][2] = 0

				return gs
			else
				# Game was played so scrape game data
				# Cycle Through Period Stats And Store In Hash
				period_data.each do |period|
					period_index = period["info"]["id"].to_i - 1
					
					gs[:scoring_summary] ||= Hash.new
					gs[:scoring_summary][:home_team] ||= Hash.new
					gs[:scoring_summary][:visiting_team] ||= Hash.new
					gs[:scoring_summary][:home_team][:goals] ||= []
					gs[:scoring_summary][:visiting_team][:goals] ||= []
					gs[:scoring_summary][:home_team][:shots] ||= []
					gs[:scoring_summary][:visiting_team][:shots] ||= []
					
					# Log Overtimes Separately So In Playoffs Multiple Overtimes Are Allowed
					if period_index > 2
						overtime_number = "OT#{period_index - 2}"
						gs[:scoring_summary][:overtimes] ||= Hash.new
						gs[:scoring_summary][:overtimes][overtime_number] ||= Hash.new
						gs[:scoring_summary][:overtimes][overtime_number][:home_team] ||= Hash.new
						gs[:scoring_summary][:overtimes][overtime_number][:visiting_team] ||= Hash.new
						gs[:scoring_summary][:overtimes][overtime_number][:number] = period_index - 2

						if period["stats"]["homeGoals"].to_i == 1
							gs[:scoring_summary][:overtimes][overtime_number][:winning_team] = home_team_id
						elsif period["stats"]["visitingGoals"].to_i == 1
							gs[:scoring_summary][:overtimes][overtime_number][:winning_team] = visiting_team_id
						else
							gs[:scoring_summary][:overtimes][overtime_number][:winning_team] = 0
						end


						gs[:scoring_summary][:overtimes][overtime_number][:home_team][:goals] = period["stats"]["homeGoals"].to_i
						gs[:scoring_summary][:overtimes][overtime_number][:home_team][:shots] = period["stats"]["homeShots"].to_i
						gs[:scoring_summary][:overtimes][overtime_number][:visiting_team][:goals] = period["stats"]["visitingGoals"].to_i
						gs[:scoring_summary][:overtimes][overtime_number][:visiting_team][:shots] = period["stats"]["visitingShots"].to_i
					else
						gs[:scoring_summary][:home_team][:goals][period_index] = period["stats"]["homeGoals"].to_i
						gs[:scoring_summary][:home_team][:shots][period_index] = period["stats"]["homeShots"].to_i
						gs[:scoring_summary][:visiting_team][:goals][period_index] = period["stats"]["visitingGoals"].to_i
						gs[:scoring_summary][:visiting_team][:shots][period_index] = period["stats"]["visitingShots"].to_i
					end
				end

				# Calculate Goal Totals
				home_goals = 0
				gs[:scoring_summary][:home_team][:goals].each do |g|
					home_goals += g.to_i
				end

				visitor_goals = 0
				gs[:scoring_summary][:visiting_team][:goals].each do |g|
					visitor_goals += g.to_i
				end

				if home_goals > visitor_goals
					gs[:winning_team_id] = gs[:home_team_id]
				elsif home_goals < visitor_goals
					gs[:winning_team_id] = gs[:visiting_team_id]
				elsif shootout == true && overtime == false # Game 1001190 From 2005 Has No Tracked Overtime, This Fixes
					gs[:winning_team_id] = doc["shootoutDetails"]["winningTeam"]["id"].to_i
				else
					gs[:scoring_summary][:overtimes].each do |overtimes, overtime|
						if overtime[:winning_team] != 0
							gs[:winning_team_id] = overtime[:winning_team]
							break
						end
					end
					gs[:winning_team_id] = doc["shootoutDetails"]["winningTeam"]["id"].to_i unless shootout == false
				end

				# Add A Goal To The Score For Shootout Winning Team
				if shootout == true || overtime == true
					gs[:home_team_id] == gs[:winning_team_id] ? home_goals += 1 : visitor_goals += 1
				end

				gs[:home_score] = home_goals
				gs[:visitor_score] = visitor_goals

				# Calculate Shot Totals
				home_shots = 0
				gs[:scoring_summary][:home_team][:shots].each do |shots|
					home_shots += shots.to_i
				end

				visitor_shots = 0
				gs[:scoring_summary][:visiting_team][:shots].each do |shots|
					visitor_shots += shots.to_i
				end

				gs[:home_shots] = home_shots
				gs[:visitor_shots] = visitor_shots

				referees_data.each do |referee|
					number = referee["jerseyNumber"].to_i
					first_name = referee["firstName"]
					last_name = referee["lastName"]
					role = referee["role"]

					gs[:game_referees] ||= Hash.new
					gs[:game_referees]["#{number}"] = { first_name: first_name,
														last_name: last_name,
														jersey_number: number,
														role: role }
				end

				linesmen_data.each do |linesman|
					number = linesman["jerseyNumber"].to_i
					first_name = linesman["firstName"]
					last_name = linesman["lastName"]
					role = linesman["role"]

					gs[:game_linesmen] ||= Hash.new
					gs[:game_linesmen]["#{number}"] = { first_name: first_name,
																								last_name: last_name,
																								jersey_number: number,
																								role: role }
				end

				# Loop Through Stars And Collect IDs
				three_stars_data.each do |star|

					team_id = star["team"]["id"].to_i
					player_id = star["player"]["info"]["id"].to_i

					gs[:three_stars] ||= Hash.new
					gs[:three_stars]["#{player_id}"] = {  team_id: team_id,
																								player_id: player_id,
																								star_number: three_stars_data.index(star) + 1}
				end
			end

			

		 	

		  	return gs
		end

		def self.team_scrape(team_data)
			skaters = Hash.new
			coaches = Hash.new
			goalies = Hash.new

			# Get Team Data (ID, Abbreviation, City)
			team_id = team_data["info"]["id"].to_i
			team_city = team_data["info"]["city"].downcase!.capitalize!
			team_nickname = team_data["info"]["nickname"].split(" ").map { |word| word.downcase!.capitalize!}.join(" ")
			team_full_name = "#{team_city} #{team_nickname}"
			team_abb = team_data["info"]["abbreviation"]

			# Isolate Coaches, Skaters And Goalies To Be Parsed
			coaches_data = team_data["coaches"]
			skaters_data = team_data["skaters"]
			goalies_data = team_data["goalies"]

		  	# Put Coaches Into Hashes
		  	coaches_data.each do |coach|
				role = coach["role"].tr(' ', '_').downcase!
				coaches[role] = { first_name: coach["firstName"],
													last_name: coach["lastName"],
													role: coach["role"],
													team_id: team_id }
			end

		  	# Put Skaters Into Hash
			skaters_data.each do |skater|
				player_id = skater["info"]["id"].to_i
				first_name = skater["info"]["firstName"]

				if skater["info"]["lastName"][-1] == "I" && skater["info"]["lastName"][-2] == " "
					last_name = skater["info"]["lastName"][0..-2]
				elsif skater["info"]["lastName"].include? "{I}"
					skater["info"]["lastName"].slice! "{I}"
					last_name = skater["info"]["lastName"].strip
				elsif skater["info"]["lastName"][-1].include? "(I)"
					skater["info"]["lastName"].slice! "(I)"
					last_name = skater["info"]["lastName"].strip
				elsif skater["info"]["lastName"].include? "(e)"
					skater["info"]["lastName"].slice! "(e)"
					last_name = skater["info"]["lastName"].strip
				else
					last_name = skater["info"]["lastName"]
				end

				number = skater["info"]["jerseyNumber"].to_i
				position = skater["info"]["position"]

				shots = skater["stats"]["shots"].to_i
				hits = skater["stats"]["hits"].to_i
				skater["status"].nil? ? nil : captaincy = skater["status"] # Set Captaincy To Nil If Not Assistant Or Captain

				skaters[number] = { player_id: player_id,
									team_id: team_id,
									first_name: first_name,
									last_name: last_name,
									number: number,
									position: position,
									shots: shots,
									hits: hits,
									captaincy: captaincy }
		  	end

		  	goalies_data.each do |goalie|
		  		player_id = goalie["info"]["id"].to_i
				  first_name = goalie["info"]["firstName"]
				  
				if goalie["info"]["lastName"][-1] == "I" && goalie["info"]["lastName"][-2] == " "
					last_name = goalie["info"]["lastName"][0..-3] # Remove the (I) that some names have afterwards
				elsif goalie["info"]["lastName"][-1] == "e" && goalie["info"]["lastName"][-2] == " "
					last_name = goalie["info"]["lastName"][0..-3] # Remove the (e) that some names have afterwards
				else
					last_name = goalie["info"]["lastName"]
				end

				number = goalie["info"]["jerseyNumber"].to_i
				position = goalie["info"]["position"]

				shots_against = goalie["stats"]["shotsAgainst"].to_i
				goals_against = goalie["stats"]["goalsAgainst"].to_i
				saves = goalie["stats"]["saves"].to_i
				time_on_ice = goalie["stats"]["timeOnIce"]
				goals = goalie["stats"]["goals"].to_i
				assists = goalie["stats"]["assists"].to_i
				points = goalie["stats"]["points"].to_i

				starting = goalie["starting"].to_i
				captaincy = goalie["status"]

				goalies[number] = { player_id: player_id,
									team_id: team_id,
									first_name: first_name,
									last_name: last_name,
									number: number,
									position: position,
									shots_against: shots_against,
									goals_against: goals_against,
									saves: saves,
									time_on_ice: time_in_seconds(time_on_ice),
									goals: goals,
									assists: assists,
									points: points,
									starting: starting,
									captaincy: captaincy }
		  end

		  return coaches, skaters, goalies, team_city, team_nickname, team_abb
		end

		def self.boxscore_scrape(home_team_id, visiting_team_id, period_data)
			goals = Hash.new
			penalties = Hash.new
			statlines = Hash.new

			goals, statlines = gather_goals(home_team_id, visiting_team_id, period_data)
			penalties = gather_penalties(home_team_id, visiting_team_id, period_data, goals)

			return goals, penalties, statlines
		end

		def self.gather_goals(home_team_id, visiting_team_id, period_data)
			goals = Hash.new
			statlines = Hash.new

			goal_counter = 1
			home_score = 0
		  	visiting_score = 0

			period_data.each do |period|
		  	# Check To Make Sure There Are Goals And Penalties Before Adding To Array
		  	period_goals_data = period["goals"]
		  	period_penalties_data = period["penalties"]

		  	period_goals_data.each do |goal|
		  		goals[goal_counter] = {}
		  		scoring_team_id = goal["team"]["id"].to_i

		  		period_number = goal["period"]["id"].to_i
		  		time = goal["time"]
		  		scorer_id = goal["scoredBy"]["id"].to_i

		  		a1_id = a2_id = nil
		  		assists = goal["assists"]
		  		assists.each do |assist|
		  			assists.index(assist) == 0 ? a1_id = assist["id"] :	a2_id = assist["id"]
		  		end

		  		plus_players = goal["plus_players"]
		  		minus_players = goal["minus_players"]
		  		plus_players_count = plus_players.count
		  		minus_players_count = minus_players.count

		  		is_penalty_shot = goal["properties"]["isPenaltyShot"].to_i
		  		is_empty_net = goal["properties"]["isEmptyNet"].to_i
		  		is_shorthanded = goal["properties"]["isShortHanded"].to_i
		  		is_powerplay = goal["properties"]["isPowerPlay"].to_i
		  		is_game_winning_goal = goal["properties"]["isGameWinningGoal"].to_i
		  		is_insurance_goal = goal["properties"]["isInsuranceGoal"].to_i

		  		# Set Game State Variables Based On Which Team Scored
		  		if scoring_team_id == home_team_id
		  			opposing_team_id = visiting_team_id
		  			home_score += 1
		  			team_score = home_score
		  			opposing_team_score = visiting_score
		  		else
		  			opposing_team_id = home_team_id
		  			visiting_score += 1
		  			team_score = visiting_score
		  			opposing_team_score = home_score
		  		end

		  		goals[goal_counter][:team_id] = scoring_team_id
		  		goals[goal_counter][:opposing_team_id] = opposing_team_id
		  		goals[goal_counter][:team_score] = team_score
		  		goals[goal_counter][:opposing_team_score] = opposing_team_score


		  		goals[goal_counter][:period] = period_number
			  	goals[goal_counter][:time] = time_in_seconds(time)
			  	goals[goal_counter][:scorer_id] = scorer_id
			  	goals[goal_counter][:a1_id] = a1_id
			  	goals[goal_counter][:a2_id] = a2_id

				goals[goal_counter][:team_player_count] = plus_players_count
				goals[goal_counter][:opposing_team_player_count] = minus_players_count

				goals[goal_counter][:is_shorthanded] = ActiveModel::Type::Boolean.new.cast(is_shorthanded)
				goals[goal_counter][:is_powerplay] = ActiveModel::Type::Boolean.new.cast(is_powerplay)
				goals[goal_counter][:is_empty_net] = ActiveModel::Type::Boolean.new.cast(is_empty_net)
				goals[goal_counter][:is_penalty_shot] = ActiveModel::Type::Boolean.new.cast(is_penalty_shot)
				goals[goal_counter][:is_game_winning_goal] = ActiveModel::Type::Boolean.new.cast(is_game_winning_goal)
				goals[goal_counter][:is_insurance_goal] = ActiveModel::Type::Boolean.new.cast(is_insurance_goal)

		  		# Create Statlines For Scorers
		  		scorers = [scorer_id, a1_id, a2_id].compact
		  		statlines[scoring_team_id] ||= {}

		  		scorers.each do |scorer|
		  			statlines[scoring_team_id][scorer] ||= {goals: 0,
															a1: 0,
															a2: 0,
															points: 0,
															ev_goals: 0,
															ev_a1: 0,
															ev_a2: 0,
															ev_points: 0,
															pp_goals: 0,
															pp_a1: 0,
															pp_a2: 0,
															pp_points: 0,
															sh_goals: 0,
															sh_a1: 0,
															sh_a2: 0,
															sh_points: 0,
															ps_goals: 0 }
		  		end

  		  		# Store Counting Stats
				if is_powerplay == 1
					statlines[scoring_team_id][scorer_id][:goals] += 1
					statlines[scoring_team_id][scorer_id][:pp_goals] += 1
					statlines[scoring_team_id][scorer_id][:points] += 1
					statlines[scoring_team_id][scorer_id][:pp_points] += 1

					if a1_id != nil
						statlines[scoring_team_id][a1_id][:a1] += 1
						statlines[scoring_team_id][a1_id][:pp_a1] += 1
						statlines[scoring_team_id][a1_id][:points] += 1
						statlines[scoring_team_id][a1_id][:pp_points] += 1
					end

					if a2_id != nil
						statlines[scoring_team_id][a2_id][:a2] += 1
						statlines[scoring_team_id][a2_id][:pp_a2] += 1
						statlines[scoring_team_id][a2_id][:points] += 1
						statlines[scoring_team_id][a2_id][:pp_points] += 1
					end

				elsif is_shorthanded == 1
					statlines[scoring_team_id][scorer_id][:goals] += 1
					statlines[scoring_team_id][scorer_id][:sh_goals] += 1
					statlines[scoring_team_id][scorer_id][:points] += 1
					statlines[scoring_team_id][scorer_id][:sh_points] += 1

					if a1_id != nil
						statlines[scoring_team_id][a1_id][:a1] += 1
						statlines[scoring_team_id][a1_id][:sh_a1] += 1
						statlines[scoring_team_id][a1_id][:points] += 1
						statlines[scoring_team_id][a1_id][:sh_points] += 1
					end

					if a2_id != nil
						statlines[scoring_team_id][a2_id][:a2] += 1
						statlines[scoring_team_id][a2_id][:sh_a2] += 1
						statlines[scoring_team_id][a2_id][:points] += 1
						statlines[scoring_team_id][a2_id][:sh_points] += 1
					end

				elsif is_penalty_shot == 1
					statlines[scoring_team_id][scorer_id][:goals] += 1
					statlines[scoring_team_id][scorer_id][:ps_goals] += 1
					statlines[scoring_team_id][scorer_id][:points] += 1
				else # Is Even Strength
					statlines[scoring_team_id][scorer_id][:goals] += 1
					statlines[scoring_team_id][scorer_id][:ev_goals] += 1
					statlines[scoring_team_id][scorer_id][:points] += 1
					statlines[scoring_team_id][scorer_id][:ev_points] += 1

					if a1_id != nil
						statlines[scoring_team_id][a1_id][:a1] += 1
						statlines[scoring_team_id][a1_id][:ev_a1] += 1
						statlines[scoring_team_id][a1_id][:points] += 1
						statlines[scoring_team_id][a1_id][:ev_points] += 1
					end

					if a2_id != nil
						statlines[scoring_team_id][a2_id][:a2] += 1
						statlines[scoring_team_id][a2_id][:ev_a2] += 1
						statlines[scoring_team_id][a2_id][:points] += 1
						statlines[scoring_team_id][a2_id][:ev_points] += 1
					end
				end

				plus_player_ids = get_on_ice_player_ids(plus_players)
				minus_player_ids = get_on_ice_player_ids(minus_players)

				goals[goal_counter][:plus_players] = plus_player_ids
				goals[goal_counter][:minus_players] = minus_player_ids

				goal_counter += 1
		  	end
		  end

		  return goals, statlines
		end

		def self.get_on_ice_player_ids(players)
			player_ids = []

			players.each do |player|
				player_ids << player["id"].to_i
			end

	  		return player_ids
		end

		def self.gather_penalties(home_team_id, visiting_team_id, period_data, goal_data)
			pp = Hash.new
			penalty_counter = 1
			team_score = 0
			opposing_team_score = 0

			period_data.each do |period|
				period_penalties = period["penalties"]

				period_penalties.each do |penalty|
					# Find Which Team Scored So ID's Can Be Entered Accordingly
					team_id = penalty["againstTeam"]["id"].to_i
					team_id == home_team_id ?	opposing_team_id = visiting_team_id :	opposing_team_id = home_team_id

					# Parse String And Input Values To Hash
					pp[penalty_counter] = { period: penalty["period"]["id"].to_i }
					pp[penalty_counter][:time] = time_in_seconds(penalty["time"]).to_i
					pp[penalty_counter][:infractor_team_id] = team_id
					pp[penalty_counter][:drawing_team_id] = opposing_team_id
					pp[penalty_counter][:duration] = time_in_seconds(penalty["minutes"]).to_i
					pp[penalty_counter][:description] = penalty["description"]

					penalty["takenBy"].nil? ? infractor_id = nil : infractor_id = penalty["takenBy"]["id"].to_i
					penalty["servedBy"].nil? ? served_id = nil : served_id = penalty["servedBy"]["id"].to_i
					pp[penalty_counter][:infractor_id] = infractor_id
					pp[penalty_counter][:served_by_id] = served_id

					# Get Goals Scored Before Penalty Was Called And Use Last One To Find Current Score
					score_state = goal_data.select {
						|goal_number, goal| (goal[:time] <= pp[penalty_counter][:time] && goal[:period] <= pp[penalty_counter][:period]) || goal[:period] < pp[penalty_counter][:period] }

					# Compare Team That Scored The Last Goal To Penalized Team And Enter Appropriate Score Accordingly
					if score_state[score_state.count].nil? # Scoreless
						pp[penalty_counter][:team_score] = 0
						pp[penalty_counter][:opposing_team_score] = 0
					elsif score_state[score_state.count][:team_id] == pp[penalty_counter][:infractor_team_id]
						pp[penalty_counter][:team_score] = score_state[score_state.count][:team_score]
						pp[penalty_counter][:opposing_team_score] = score_state[score_state.count][:opposing_team_score]
					else
						pp[penalty_counter][:team_score] = score_state[score_state.count][:opposing_team_score]
						pp[penalty_counter][:opposing_team_score] = score_state[score_state.count][:team_score]
					end

					penalty_counter += 1
			  	end
			end

		  	return pp
		end

		def self.scrape_shootout_attempts(attempts, shooting_team_id, defending_team_id)
			sa = Hash.new
			shot_counter = 1

			attempts.each do |attempt|
				sa[shot_counter] = Hash.new

				shooter_id = attempt["shooter"]["id"].to_i
				goalie_id = attempt["goalie"]["id"].to_i
				is_goal = ActiveModel::Type::Boolean.new.cast(attempt["isGoal"])
				is_winning_goal = ActiveModel::Type::Boolean.new.cast(attempt["isGameWinningGoal"])

				sa[shot_counter][:shooter_id] = shooter_id
				sa[shot_counter][:goalie_id] = goalie_id
				sa[shot_counter][:is_goal] = is_goal
				sa[shot_counter][:is_winning_goal] = is_winning_goal
				sa[shot_counter][:shooting_team_id] = shooting_team_id
				sa[shot_counter][:defending_team_id] = defending_team_id
				sa[shot_counter][:shot_number] = shot_counter

				shot_counter += 1
			end

			return sa
		end

		def self.scrape_penalty_shots(penalty_shots, shooting_team_id, defending_team_id)
			game_penalty_shots = Hash.new
			penalty_shot_counter = 1

			penalty_shots.each do |penalty_shot|
				game_penalty_shots[penalty_shot_counter] = Hash.new

				shooter_id = penalty_shot["shooter"]["id"].to_i
				goalie_id = penalty_shot["goalie"]["id"].to_i
				period = penalty_shot["period"]["id"].to_i
				time = time_in_seconds(penalty_shot["time"]).to_i
				is_goal = ActiveRecord::Type::Boolean.new.cast(penalty_shot["isGoal"])

				game_penalty_shots[penalty_shot_counter][:shooter_id] = shooter_id
				game_penalty_shots[penalty_shot_counter][:goalie_id] = goalie_id
				game_penalty_shots[penalty_shot_counter][:period] = period
				game_penalty_shots[penalty_shot_counter][:time] = time
				game_penalty_shots[penalty_shot_counter][:is_goal] = is_goal
				game_penalty_shots[penalty_shot_counter][:shooting_team_id] = shooting_team_id
				game_penalty_shots[penalty_shot_counter][:defending_team_id] = defending_team_id

				penalty_shot_counter += 1
			end

			return game_penalty_shots
		end

		#
		# INPUT TO DATABASE FUNCTION
		#

		def self.add_game(game_info)
			season = Season.find_by(cwhl_id: game_info[:season_id])

			add_team(game_info[:home_team_id], game_info[:home_team_city], game_info[:home_team_name], game_info[:home_team_abbreviation], game_info[:season_id])
			add_team(game_info[:visiting_team_id], game_info[:visiting_team_city], game_info[:visiting_team_name], game_info[:visiting_team_abbreviation], game_info[:season_id])

			# This Is For Player Creation So Team Info Is Available When Creating A New Player
			home_team_statline = TeamStatline.find_by(season_id: game_info[:season_id], team_code: game_info[:home_team_id]) 
			visiting_team_statline = TeamStatline.find_by(season_id: game_info[:season_id], team_code: game_info[:visiting_team_id])

			add_season(game_info[:season_id]) if season.nil?

			total_goals = game_info[:game_scoring].count

			begin
				Game.where(cwhl_game_id: game_info[:game_id].to_i).first_or_create.update_attributes(
					id: game_info[:game_id].to_i,
					game_date: game_info[:game_date],
					season_id: game_info[:season_id],
					is_playoffs: season.is_playoffs,
					is_forfeit: !game_info[:status],
					venue: game_info[:venue],
					duration: time_in_seconds(game_info[:duration]).to_i, # Time Is Actually Minutes
					start_time: game_info[:start_time],
					end_time: game_info[:end_time],
					periods: game_info[:periods].to_i,
					game_number: game_info[:game_number].to_i,
					attendance: game_info[:attendance].to_i,
					home_team_id: game_info[:home_team_id].to_i,
					visiting_team_id: game_info[:visiting_team_id].to_i,
					home_score: game_info[:home_score].to_i,
					visitor_score: game_info[:visitor_score].to_i,
					home_shots: game_info[:home_shots].to_i,
					visitor_shots: game_info[:visitor_shots].to_i,
					overtime: game_info[:overtime],
					shootout: game_info[:shootout],
					winning_team_id: game_info[:winning_team_id],
					first_period_home_goals: game_info[:scoring_summary][:home_team][:goals][0],
					first_period_home_shots: game_info[:scoring_summary][:home_team][:shots][0],
					first_period_visitor_goals: game_info[:scoring_summary][:visiting_team][:goals][0],
					first_period_visitor_shots: game_info[:scoring_summary][:visiting_team][:shots][0],
					second_period_home_goals: game_info[:scoring_summary][:home_team][:goals][1],
					second_period_home_shots: game_info[:scoring_summary][:home_team][:shots][1],
					second_period_visitor_goals: game_info[:scoring_summary][:visiting_team][:goals][1],
					second_period_visitor_shots: game_info[:scoring_summary][:visiting_team][:shots][1],
					third_period_home_goals: game_info[:scoring_summary][:home_team][:goals][2],
					third_period_home_shots: game_info[:scoring_summary][:home_team][:shots][2],
					third_period_visitor_goals: game_info[:scoring_summary][:visiting_team][:goals][2],
					third_period_visitor_shots: game_info[:scoring_summary][:visiting_team][:shots][2],
					goals_count: total_goals,
					game_name: "#{game_info[:visiting_team_abbreviation]} @ #{game_info[:home_team_abbreviation]}",
					home_abbreviation: game_info[:home_team_abbreviation],
					visitor_abbreviation: game_info[:visiting_team_abbreviation])
			rescue ActiveRecord::RecordNotUnique
			  retry
			end

			g = Game.find_by(cwhl_game_id: game_info[:game_id])
			g.update_attributes(updated_at: Time.now)

			if g.overtime == true
				game_info[:scoring_summary][:overtimes].each do |overtime_periods, overtime|
					add_overtime(overtime, g)
				end

				home_ts = game_info[:home_shots].to_i
				visitor_ts = game_info[:visitor_shots].to_i
				g.overtimes.each do |o|
					home_ts += o.home_shots
					visitor_ts += o.visitor_shots
				end

				g.update_attributes(home_total_shots: home_ts, visitor_total_shots: visitor_ts)

			else
				g.update_attributes(home_total_shots: game_info[:home_shots].to_i, visitor_total_shots: game_info[:visitor_shots].to_i)
			end

			# Add Skaters To DB
			add_skaters(g, game_info[:home_skaters], game_info[:game_statlines][g.home_team_id], season, home_team_statline, game_info[:visiting_team_id], true)
			add_skaters(g, game_info[:visiting_skaters], game_info[:game_statlines][g.visiting_team_id], season, visiting_team_statline, game_info[:home_team_id], false)

			# Add Goalies To DB
			add_goalies(g, game_info[:home_goalies], game_info[:home_team_abbreviation], season)
			add_goalies(g, game_info[:visiting_goalies], game_info[:visiting_team_abbreviation], season)

			# Add Coaches To DB
			add_coaches(g, game_info[:home_coaches]) # unless game_info[:home_coaches].nil?
			add_coaches(g, game_info[:visiting_coaches]) # unless game_info[:visiting_coaches].nil?

			# Add Referees To DB
			add_referees(g, game_info[:game_referees]) unless game_info[:game_referees].nil?
			add_referees(g, game_info[:game_linesmen]) unless game_info[:game_linesmen].nil?

			# Add 3 Stars To DB
			add_stars(g, game_info[:three_stars]) unless game_info[:three_stars].nil?

			# Add Goals
			h, v = add_goals(g, game_info[:game_scoring])

			# Add Penalties
			add_penalties(g, game_info[:game_penalties])

			# Add Shootout Attempts
			if g.shootout == true
				add_shootout_attempts(g, game_info[:home_shootout_attempts])
				add_shootout_attempts(g, game_info[:visiting_shootout_attempts])
			end

			# Add Penalty Shots
			add_penalty_shots(g, game_info[:home_penalty_shots])
			add_penalty_shots(g, game_info[:visitor_penalty_shots])

			# Add Team Game Statlines
			add_game_statlines(g)
		end

		#
		# INPUT TO DATABASE HELPER FUNCTIONS
		#

		def self.add_season(season_id)
			url = "https://lscluster.hockeytech.com/feed/index.php?feed=statviewfeed&view=bootstrap&season=latest&pageName=schedule&key=50c2cd9b5e18e390&client_code=ahl&site_id=1&league_id=&league_code=&lang=en&callback=angular.callbacks._2"
		  doc = Nokogiri::HTML(open(url))

		  seasons_data = doc.to_s[/seasons\"\:(.*?)\}\]\,/].scan(/\{(.*?)\}/)
		  season_name = ""

		  seasons_data.each do |season|
		  	s_id = season.to_s[/\"id(.*?)\,/][/\d+/].to_i

				if season_id == s_id
					season_name = season.to_s[/"name(.*?)\,/].split(':')[1].tr(',', '').tr('"', '').tr('\\', '').to_s
					break
				end
		  end

		  is_playoffs = false
			is_regular_season = false
			is_allstar_game = false
			is_playoffs = false
			is_exhibition = false

		  if !season_name[/Exhibition/].nil?
		  	year_start = year_end = nil
		  	abbreviation = "EX"
		  	is_exhibition = true
		  elsif !season_name[/Regular/].nil?
		  	year_start = season_name[/(.*?)\-/].to_i
		  	year_end = year_start + 1
		  	abbreviation = "#{year_start.to_s[2..3]}-#{year_end.to_s[2..3]}"
		  	is_regular_season = true
		  elsif !season_name[/Playoffs/].nil?
		  	year_start = year_end = season_name[/(.*?) /].to_i
		  	abbreviation = "#{year_start.to_s[2..3]}PO"
		  	is_playoffs = true
		  elsif !season_name[/All-Star/].nil?
		  	is_allstar_game = true
		  	year_start = year_end = season_name[/(.*?) /].to_i
		  	abbreviation = "#{year_start.to_s[2..3]}PO"
		  	is_allstar_game = true
		  end

		  # Calculate Start And End Dates
			if is_regular_season == true
				start_date_url = "https://lscluster.hockeytech.com/feed/index.php?feed=statviewfeed&view=schedule&team=-1&season=#{season_id}&month=10&location=homeaway&key=50c2cd9b5e18e390&client_code=ahl&site_id=1&league_id=4&division_id=-1&lang=en&callback=angular.callbacks._3:formatted"
				doc = Nokogiri::HTML(open(start_date_url))
				start_date = Date.parse(doc.to_s[/"data(.*?)\]/][/"date_with_day(.*?)"\,/].split(':')[1].tr(',', '').tr('"', '') + " #{year_start}")

				end_date_url = "https://lscluster.hockeytech.com/feed/index.php?feed=statviewfeed&view=schedule&team=-1&season=#{season_id}&month=4&location=homeaway&key=50c2cd9b5e18e390&client_code=ahl&site_id=1&league_id=4&division_id=-1&lang=en&callback=angular.callbacks._3:formatted"
				doc = Nokogiri::HTML(open(end_date_url))
				end_date = Date.parse(doc.to_s[/"data(.*?)\]/].scan(/"date_with_day(.*?)"\,/)[-1].to_s.tr('"', '').tr(']', '').tr('\\','') + " #{year_end}")
			elsif is_playoffs == true
				po_start_date_url = "https://lscluster.hockeytech.com/feed/index.php?feed=statviewfeed&view=schedule&team=-1&season=#{season_id}&month=4&location=homeaway&key=50c2cd9b5e18e390&client_code=ahl&site_id=1&league_id=4&division_id=-1&lang=en&callback=angular.callbacks._3"
				doc = Nokogiri::HTML(open(po_start_date_url))
				start_date = Date.parse(doc.to_s[/"data(.*?)\]/][/"date_with_day(.*?)"\,/].split(':')[1].tr(',', '').tr('"', '') + " #{year_start}")

				end_date_url = "https://lscluster.hockeytech.com/feed/index.php?feed=statviewfeed&view=schedule&team=-1&season=#{season_id}&month=06&location=homeaway&key=50c2cd9b5e18e390&client_code=ahl&site_id=1&league_id=4&division_id=-1&lang=en&callback=angular.callbacks._3:formatted"
				doc = Nokogiri::HTML(open(end_date_url))
				end_date = Date.parse(doc.to_s[/"data(.*?)\]/].scan(/"date_with_day(.*?)"\,/)[-1].to_s + " #{year_end}")
			end

		  s = Season.new(	cwhl_id: season_id,
											name: season_name,
											year_start: year_start,
											year_end: year_end,
											start_date: start_date,
											end_date: end_date,
											abbreviation: abbreviation,
											is_regular_season: is_regular_season,
											is_playoffs: is_playoffs,
											is_allstar_game: is_allstar_game,
											is_exhibition: is_exhibition)
			s.save
		end

		def self.add_overtime(overtime, game)
			ot_number = overtime[:number]
			home_shots = overtime[:home_team][:shots]
			home_goals = overtime[:home_team][:goals]
			visiting_shots = overtime[:visiting_team][:shots]
			visiting_goals = overtime[:visiting_team][:goals]

			o = Overtime.new(game_id: game.id,
												cwhl_game_id: game.cwhl_game_id,
												season_id: game.season_id,
												home_team_id: game.home_team_id,
												visiting_team_id: game.visiting_team_id,
												overtime_number: ot_number,
												home_shots: home_shots,
												home_goals: home_goals,
												visitor_shots: visiting_shots,
												visitor_goals: visiting_goals)
			o.save
		end

		def self.add_team(team_code, team_city, team_name, team_abb, season_id)
			team_city == "Wilkes-Barre/Scranton" ? game_file_city = "W-B/Scranton" : game_file_city = team_city #
			team_abb = "MB" if team_name == "Moose" && team_city == "Manitoba" && team_code == 321 # Older Seasons Used MTB, Consolidate!
			team_abb = "GR" if team_name == "Griffins" && team_city == "Grand Rapids" && team_code == 328 # Older Seasons Used GRA, Consolidate!

			safe_name = team_name.tr(" ", "_").downcase
			safe_abb = team_abb.downcase
			logo_url = "#{team_code}_#{safe_abb}_#{safe_name}.png"
			season = Season.find_by(cwhl_id: season_id)

			begin
				Team.where(team_code: team_code, city: team_city, name: team_name).first_or_create.update_attributes(
					game_file_city: game_file_city,
					abbreviation: team_abb,
					logo_url: logo_url)
			rescue ActiveRecord::RecordNotUnique
			  retry
			end

			team = Team.find_by(city: team_city, name: team_name, team_code: team_code, abbreviation: team_abb)

			begin
				TeamStatline.where(team_id: team.id, season_id: season_id, team_code: team_code).first_or_create.update_attributes(
					city: team_city,
					name: team_name,
					season_abbreviation: season.abbreviation,
					full_name: "#{team_city} #{team_name}",
					abbreviation: team_abb)
			rescue ActiveRecord::RecordNotUnique
			  retry
			end
		end

		def self.add_skaters(game, skaters, skater_statlines, season, team_statline, opposing_team_id, is_home_game)
			skaters.each do |n, s|
				next if s[:first_name] == nil # Some Seasons Have Blank Players, Skip Them

				begin
					Player.where(id: s[:player_id]).first_or_create.update_attributes(	cwhl_id: s[:player_id],
																						first_name: s[:first_name],
																						last_name: s[:last_name],
																						position: s[:position])
				rescue ActiveRecord::RecordNotUnique
					retry
				end

				begin
					Skater.where(player_id: s[:player_id], team_id: s[:team_id], season_id: game.season_id).first_or_create.update_attributes(first_name: s[:first_name],
																																				last_name: s[:last_name],
																																				full_name: "#{s[:first_name]} #{s[:last_name]}",
																																				position: s[:position],
																																				captain: s[:captaincy],
																																				number: s[:number],
																																				season_abbreviation: season.abbreviation,
																																				team_abbreviation: team_statline.abbreviation)
				rescue ActiveRecord::RecordNotUnique
					retry
				end

				# Find Current Skater's Stats
				skater_statlines.nil? ? skater_stats = nil : skater_stats = skater_statlines[s[:player_id]]

				s[:captaincy] = nil unless s[:captaincy] == "C" || s[:captaincy] == "A"  # Make Sure No Gibberish Is Added

				# Add Player Game Record Using Player ID
				begin
					PlayerGameStatline.where(player_id: s[:player_id], game_id: game.cwhl_game_id).first_or_create.update_attributes(
						 team_id: s[:team_id],
						 opposing_team_id: opposing_team_id,
						 is_home_game: is_home_game,
						 season_id: game.season_id,
						 first_name: s[:first_name],
						 last_name: s[:last_name],
						 position: s[:position],
						 number: s[:number],
						 captaincy: s[:captaincy],
						 shots: s[:shots],
						 game_date: game.game_date,
						 game_name: "#{game.visitor_abbreviation} @ #{game.home_abbreviation}")
				rescue ActiveRecord::RecordNotUnique
				  retry
				end

				pgs = PlayerGameStatline.find_by(player_id: s[:player_id], game_id: game.cwhl_game_id)

				# Input Counting Stats
				if !skater_stats.nil?
					pgs.update_attributes(goals: skater_stats[:goals],
																 a1: skater_stats[:a1],
																 a2: skater_stats[:a2],
																 points: skater_stats[:points],
																 ev_goals: skater_stats[:ev_goals],
																 ev_a1: skater_stats[:ev_a1],
																 ev_a2: skater_stats[:ev_a2],
																 ev_points: skater_stats[:ev_points],
																 pp_goals: skater_stats[:pp_goals],
																 pp_a1: skater_stats[:pp_a1],
																 pp_a2: skater_stats[:pp_a2],
																 pp_points: skater_stats[:pp_points],
																 sh_goals: skater_stats[:sh_goals],
																 sh_a1: skater_stats[:sh_a1],
																 sh_a2: skater_stats[:sh_a2],
																 sh_points: skater_stats[:sh_points],
																 ps_goals: skater_stats[:ps_goals] )

				# Player Didn't Score, Set Statline To 0's
				else
					pgs.update_attributes(	goals: 0,
											a1: 0,
											a2: 0,
											points: 0,
											ev_goals: 0,
											ev_a1: 0,
											ev_a2: 0,
											ev_points: 0,
											pp_goals: 0,
											pp_a1: 0,
											pp_a2: 0,
											pp_points: 0,
											sh_goals: 0,
											sh_a1: 0,
											sh_a2: 0,
											sh_points: 0,
											ps_goals: 0 )
				end
			end
		end

		def self.add_goalies(game, goalies, abbreviation, season)
			goalies.each do |n, g|
				next if g[:first_name] == nil # Some Seasons Have Blank Players, Skip Them

				# Check If Player Record Exists (If Not Create It)
				begin
					Player.where(id: g[:player_id]).first_or_create.update_attributes(	cwhl_id: g[:player_id],
																						first_name: g[:first_name],
																						last_name: g[:last_name],
																						position: g[:position])
			 	rescue ActiveRecord::RecordNotUnique
					retry
				end

				begin
					Goalie.where(player_id: g[:player_id], team_id: g[:team_id], season_id: game.season_id).first_or_create.update_attributes(	first_name: g[:first_name],
																																				last_name: g[:last_name],
																																				position: g[:position],
																																				team_abbreviation: abbreviation,
																																				captaincy: g[:captaincy],
																																				number: g[:number],
																																				season_abbreviation: season.abbreviation,)
				rescue ActiveRecord::RecordNotUnique
					retry
				end

				g[:captaincy] = nil unless g[:captaincy] == "C" || g[:captaincy] == "A" # Make Sure No Gibberish Is Added

				# If Goalie Played Get Save Percentage
				if g[:time_on_ice] == 0
					sp = 0
				else
					sp = BigDecimal.new(g[:saves]) / BigDecimal.new(g[:shots_against])
				end

				# Add Player Game Record Using Player ID
				begin
					GoalieGameStatline.where(player_id: g[:player_id], game_id: game.cwhl_game_id).first_or_create.update_attributes(
						team_id: g[:team_id],
						season_id: game.season_id,
						first_name: g[:first_name],
						last_name: g[:last_name],
						position: g[:position],
						number: g[:number],
						captaincy: g[:captaincy],
						shots_against: g[:shots_against],
						goals_against: g[:goals_against],
						saves: g[:saves],
						save_percent: sp,
						time_on_ice: g[:time_on_ice],
						goals: g[:goals],
						assists: g[:assists],
						points: g[:points],
						starting: g[:starting],
						game_date: game.game_date,
						game_name: "#{game.visitor_abbreviation} @ #{game.home_abbreviation}")
			 	rescue ActiveRecord::RecordNotUnique
					retry
				end
			end
		end

		def self.add_coaches(game, coaches)
			Coach.where(game_id: game.cwhl_game_id).destroy_all # Remove all coaches so that duplicates aren't made on re-scrape

			coaches.each do |n, c|
				coach = Coach.new(first_name: c[:first_name],
											last_name: c[:last_name],
											game_id: game.cwhl_game_id,
											season_id: game.season_id,
											team_id: c[:team_id],
											role: c[:role])
				coach.save
			end
		end

		def self.add_referees(game, referees)
			Referee.where(game_id: game.cwhl_game_id).destroy_all # Remove all referees so that duplicates aren't made on re-scrape

			referees.each do |n, r|
				referee = Referee.new(season_id: game.season_id,
															 game_id: game.cwhl_game_id,
															 first_name: r[:first_name],
															 last_name: r[:last_name],
															 number: r[:jersey_number],
															 position: r[:role])
				referee.save
			end
		end

		def self.add_stars(game, stars)
			Star.where(game_id: game.cwhl_game_id).destroy_all # Remove all stars so that duplicates aren't made on re-scrape
			stars.each do |n, s|
				star = Star.new(game_id: game.cwhl_game_id,
												player_id: s[:player_id],
												team_id: s[:team_id],
												number: s[:star_number],
												season_id: game.season_id)
				star.save
			end
		end

		def self.add_goals(game, goals)
			home_score = 0
			visitor_score = 0
			Goal.where(game_id: game.cwhl_game_id).destroy_all # Remove all goals from game in case time of a goal is changed so it won't duplicate on re-scrape

			goals.each do |n, g|
				goal = Goal.new(game_id: game.cwhl_game_id,
												team_id: g[:team_id],
												season_id: game.season_id,
												goalscorer_id: g[:scorer_id],
												a1_id: g[:a1_id],
												a2_id: g[:a2_id],
												opposing_team_id: g[:opposing_team_id],
												team_score: g[:team_score],
												opposing_team_score: g[:opposing_team_score],
												period: g[:period],
												time: g[:time],
												game_time_elapsed: (g[:period] * 1200 - 1200) + g[:time],
												is_empty_net: g[:is_empty_net],
												is_powerplay: g[:is_powerplay],
												is_shorthanded: g[:is_shorthanded],
												is_penalty_shot: g[:is_penalty_shot],
												team_player_count: g[:team_player_count],
												opposing_team_player_count: g[:opposing_team_player_count])

				unless goal.save
				 	goal = Goal.find_by(game_id: game.cwhl_game_id, period: g[:period], time: g[:time])
				end

				if g[:team_id].to_i == game.home_team_id.to_i
					home_score += 1
				else
					visitor_score += 1
				end

				add_on_ice_skaters(game, goal, g[:plus_players], true, g[:team_player_count], g[:opposing_team_player_count])
				add_on_ice_skaters(game, goal, g[:minus_players], false, g[:opposing_team_player_count], g[:team_player_count])
			end

			return home_score, visitor_score
		end

		def self.add_on_ice_skaters(game, goal, skaters, is_plus, teammate_count, opposing_skaters_count)
			team_id = is_plus ? goal.team_id : goal.opposing_team_id

			skaters.each do |s|
				received_point = true if goal.goalscorer_id == s || goal.a1_id == s || goal.a2_id == s
				ois = OnIceSkater.new(game_id: game.cwhl_game_id,
															game_date: game.game_date,
															goal_id: goal.id,
															period: goal.period,
															time: goal.time,
															team_id: team_id,
															season_id: game.season_id,
															player_id: s,
															on_scoring_team: is_plus,
															is_shorthanded: goal.is_shorthanded,
															is_powerplay: goal.is_powerplay,
															is_empty_net: goal.is_empty_net,
															received_point: received_point,
															teammate_count: teammate_count,
															opposing_skaters_count: opposing_skaters_count)
				ois.save
			end
		end

		def self.add_penalties(game, penalties)
			Penalty.where(game_id: game.cwhl_game_id).destroy_all # Remove penalties from game just in case time was changed so that penalties aren't duplicated on re-scraped
			
			penalties.each do |n, p|
				is_minor = false
				is_double_minor = false
				is_major = false
				is_fight = false
				is_misconduct = false
				is_game_misconduct = false

				if p[:description].downcase.include?("double minor") && p[:duration].to_i == 240
					is_double_minor = true
				elsif p[:description].downcase.include?("major") && p[:duration].to_i == 300
					is_major = true
				elsif p[:description].downcase.include?("fighting") && p[:duration].to_i == 300
					is_fight = true
				elsif p[:description].downcase.include?("misconduct") && !p[:description].downcase.include?("game") && p[:duration].to_i == 600
					is_misconduct = true
				elsif p[:description].downcase.include?("game misconduct") && p[:duration].to_i == 600
					is_game_misconduct = true
				elsif p[:duration].to_i == 120
					is_minor = true
				end

				penalty = Penalty.new(game_id: game.cwhl_game_id,
										player_id: p[:infractor_id],
										period: p[:period],
										time: p[:time],
										serving_player_id: p[:served_by_id],
										description: p[:description],
										season_id: game.season_id,
										team_id: p[:infractor_team_id],
										drawing_team_id: p[:drawing_team_id],
										duration: p[:duration],
										team_score: p[:team_score],
										opposing_team_score: p[:opposing_team_score],
										game_date: game.game_date,
										game_name: game.game_abbreviation,
										game_time_elapsed: (p[:period].to_i * 1200 - 1200) + p[:time],
										is_minor: is_minor,
										is_double_minor: is_double_minor,
										is_major: is_major,
										is_fight: is_fight,
										is_misconduct: is_misconduct,
										is_game_misconduct: is_game_misconduct)
				penalty.save
			end
		end

		def self.add_shootout_attempts(game, attempts)
			ShootoutAttempt.where(game_id: game[:cwhl_game_id]).destroy_all # Remove all shootout attempts so that there are no duplicates on re-scrape

			attempts.each do |shot, attempt|
				s = ShootoutAttempt.new(player_id: attempt[:shooter_id],
																game_id: game[:cwhl_game_id],
																season_id: game[:season_id],
																goalie_id: attempt[:goalie_id],
																scored: attempt[:is_goal],
																game_winner: attempt[:is_winning_goal],
																team_id: attempt[:shooting_team_id],
																defending_team_id: attempt[:defending_team_id],
																shot_number: attempt[:shot_number])
				s.save
			end
		end

		def self.add_penalty_shots(game, attempts)
			# Create A Hash Of Goals To Add To PlayerGameStatline Totals
			penalty_shot_goals = {}
			PenaltyShot.where(game_id: game[:cwhl_game_id]).destroy_all # Remove all penalty shots so on re-scrape no duplicates can be made

			attempts.each do |shot, attempt|
				ps = PenaltyShot.new(player_id: attempt[:shooter_id],
														game_id: game[:cwhl_game_id],
														season_id: game[:season_id],
														goalie_id: attempt[:goalie_id],
														scored: attempt[:is_goal],
														team_id: attempt[:shooting_team_id],
														defending_team_id: attempt[:defending_team_id],
														period: attempt[:period],
														time: attempt[:time])
				ps.save

				# Add Player To Penalty Shot Hash
				penalty_shot_goals[attempt[:shooter_id]] = 0 unless penalty_shot_goals.key?(attempt[:shooter_id])

				# If Player Scored Add A Goal To Their Tally
				if attempt[:is_goal] == true
					penalty_shot_goals[attempt[:shooter_id]] += 1
				end
			end

			# Cycle Through Players And Update Statline With Their Penalty Shot Goal Totals
			penalty_shot_goals.each do |id, goals|
				player = PlayerGameStatline.find_by(player_id: id, game_id: game.cwhl_game_id)
				player.ps_goals = goals
				player.save
			end
		end

		def self.add_game_statlines(game)
  		home_team = {}
  		visiting_team = {}

  		home_ev_goals = game.goals.where(team_id: game.home_team_id, is_empty_net: false, is_powerplay: false, is_shorthanded: false, is_penalty_shot: false).count
  		visitor_ev_goals = game.goals.where(team_id: game.visiting_team_id, is_empty_net: false, is_powerplay: false, is_shorthanded: false, is_penalty_shot: false).count
  		home_pp_goals = game.goals.where(team_id: game.home_team_id, is_empty_net: false, is_powerplay: true).count
  		visitor_pp_goals = game.goals.where(team_id: game.visiting_team_id, is_empty_net: false, is_powerplay: true).count
  		home_sh_goals = game.goals.where(team_id: game.home_team_id, is_empty_net: false, is_shorthanded: true).count
  		visitor_sh_goals = game.goals.where(team_id: game.visiting_team_id, is_empty_net: false, is_shorthanded: true).count
  		home_en_goals = game.goals.where(team_id: game.home_team_id, is_empty_net: true).count
  		visitor_en_goals = game.goals.where(team_id: game.visiting_team_id, is_empty_net: true).count

			home_ot_shots, home_ot_goals = game.home_overtime_shots_goals
			visitor_ot_shots, visitor_ot_goals = game.visitor_overtime_shots_goals

  		# Goal Added By Shootout Needs To Be Accounted For
  		if game.shootout == true
  			if game.winning_team_id == game.home_team_id
  				home_so_goals = 1
  				visitor_so_goals = 0
  			else
  				home_so_goals = 0
  				visitor_so_goals = 1
  			end
  		end

  		if game.winning_team_id == game.home_team_id
  			visiting_team[:won] = false
  			home_team[:won] = true
  		else
  			visiting_team[:won] = true
  			home_team[:won] = false
  		end

  		# Set Home Team
  		home_team[:id] = game.home_team_id
  		home_team[:abbreviation] = TeamStatline.find_by(season_id: game.season_id, team_code: game.home_team_id).abbreviation
  		home_team[:home_team] = true
  		home_team[:goals] = game.home_score
  		home_team[:goals_against] = game.visitor_score
  		home_team[:shots] = game.home_shots
  		home_team[:shots_against] = game.visitor_shots
  		home_team[:opponent_id] = game.visiting_team_id
  		home_team[:opponent_abbreviation] = TeamStatline.find_by(season_id: game.season_id, team_code: game.visiting_team_id).abbreviation

  		home_team[:p1_goals] = game.first_period_home_goals
  		home_team[:p2_goals] = game.second_period_home_goals
  		home_team[:p3_goals] = game.third_period_home_goals
  		home_team[:p3_goals] = game.third_period_home_goals
  		home_team[:ot_goals] = home_ot_goals
  		home_team[:p1_shots] = game.first_period_home_shots
  		home_team[:p2_shots] = game.second_period_home_shots
  		home_team[:p3_shots] = game.third_period_home_shots
  		home_team[:ot_shots] = home_ot_shots

  		home_team[:p1_goals_against] = game.first_period_visitor_goals
  		home_team[:p2_goals_against] = game.second_period_visitor_goals
  		home_team[:p3_goals_against] = game.third_period_visitor_goals
  		home_team[:p3_goals_against] = game.third_period_visitor_goals
  		home_team[:ot_goals_against] = visitor_ot_goals
  		home_team[:p1_shots_against] = game.first_period_visitor_shots
  		home_team[:p2_shots_against] = game.second_period_visitor_shots
  		home_team[:p3_shots_against] = game.third_period_visitor_shots
  		home_team[:ot_shots_against] = visitor_ot_shots

  		home_team[:ev_goals] = home_ev_goals
  		home_team[:ev_goals_against] = visitor_ev_goals
  		home_team[:pp_goals] = home_pp_goals
  		home_team[:pp_goals_against] = visitor_pp_goals
  		home_team[:sh_goals] = home_sh_goals
  		home_team[:sh_goals_against] = visitor_sh_goals
  		home_team[:en_goals] = home_en_goals
  		home_team[:en_goals_against] = visitor_en_goals
  		home_team[:so_goals] = home_so_goals
  		home_team[:so_goals_against] = visitor_so_goals

  		# Set Visiting Team
  		visiting_team[:id] = game.visiting_team_id
  		visiting_team[:abbreviation] = TeamStatline.find_by(season_id: game.season_id, team_code: game.visiting_team_id).abbreviation
  		visiting_team[:home_team] = false
  		visiting_team[:goals] = game.visitor_score
  		visiting_team[:goals_against] = game.home_score
  		visiting_team[:shots] = game.visitor_shots
  		visiting_team[:shots_against] = game.home_shots
  		visiting_team[:opponent_id] = game.home_team_id
  		visiting_team[:opponent_abbreviation] = TeamStatline.find_by(season_id: game.season_id, team_code: game.home_team_id).abbreviation

  		visiting_team[:p1_goals] = game.first_period_visitor_goals
  		visiting_team[:p2_goals] = game.second_period_visitor_goals
  		visiting_team[:p3_goals] = game.third_period_visitor_goals
  		visiting_team[:p3_goals] = game.third_period_visitor_goals
  		visiting_team[:ot_goals] = visitor_ot_goals
  		visiting_team[:p1_shots] = game.first_period_visitor_shots
  		visiting_team[:p2_shots] = game.second_period_visitor_shots
  		visiting_team[:p3_shots] = game.third_period_visitor_shots
  		visiting_team[:ot_shots] = visitor_ot_shots

  		visiting_team[:p1_goals_against] = game.first_period_home_goals
  		visiting_team[:p2_goals_against] = game.second_period_home_goals
  		visiting_team[:p3_goals_against] = game.third_period_home_goals
  		visiting_team[:p3_goals_against] = game.third_period_home_goals
  		visiting_team[:ot_goals_against] = home_ot_goals
  		visiting_team[:p1_shots_against] = game.first_period_home_shots
  		visiting_team[:p2_shots_against] = game.second_period_home_shots
  		visiting_team[:p3_shots_against] = game.third_period_home_shots
  		visiting_team[:ot_shots_against] = home_ot_shots

  		visiting_team[:ev_goals] = visitor_ev_goals
  		visiting_team[:ev_goals_against] = home_ev_goals
  		visiting_team[:pp_goals] = visitor_pp_goals
  		visiting_team[:pp_goals_against] = home_pp_goals
  		visiting_team[:sh_goals] = visitor_sh_goals
  		visiting_team[:sh_goals_against] = home_sh_goals
  		visiting_team[:en_goals] = visitor_en_goals
  		visiting_team[:en_goals_against] = home_en_goals
  		visiting_team[:so_goals] = visitor_so_goals
  		visiting_team[:so_goals_against] = home_so_goals

  		add_team_game_statline(home_team, game)
  		add_team_game_statline(visiting_team, game)
	  end

		def self.add_team_game_statline(team, game)
			begin
				TeamGameStatline.where(game_id: game.cwhl_game_id, team_id: team[:id]).first_or_create.update_attributes(
					season_id: game.season_id,
					abbreviation: team[:abbreviation],
					game_date: game.game_date,
					home_team: team[:home_team],
					overtime: game.overtime,
					shootout: game.shootout,
					goals_for: team[:goals],
					goals_against: team[:goals_against],
					p1_goals: team[:p1_goals],
					p2_goals: team[:p2_goals],
					p3_goals: team[:p3_goals],
					p1_goals_against: team[:p1_goals_against],
					p2_goals_against: team[:p2_goals_against],
					p3_goals_against: team[:p3_goals_against],
					shots_for: team[:shots],
					shots_against: team[:shots_against],
					p1_shots: team[:p1_shots],
					p2_shots: team[:p2_shots],
					p3_shots: team[:p3_shots],
					p1_shots_against: team[:p1_shots_against],
					p2_shots_against: team[:p2_shots_against],
					p3_shots_against: team[:p3_shots_against],
					ev_goals: team[:ev_goals],
					ev_goals_against: team[:ev_goals_against],
					pp_goals: team[:pp_goals],
					pp_goals_against: team[:pp_goals_against],
					sh_goals: team[:sh_goals],
					sh_goals_against: team[:sh_goals_against],
					en_goals: team[:en_goals],
					en_goals_against: team[:en_goals_against],
					so_goals: team[:so_goals],
					so_goals_against: team[:so_goals_against],
					ot_goals: team[:ot_goals],
					ot_goals_against: team[:ot_goals_against],
					ot_shots: team[:ot_shots],
					ot_shots_against: team[:ot_shots_against],
					ot_periods: game.overtimes.count,
					opponent_id: team[:opponent_id],
					opponent_abbreviation: team[:opponent_abbreviation],
					won: team[:won]
				)
			rescue ActiveRecord::RecordNotUnique
				retry
			end
		end

		#
		# HELPER FUNCTIONS
		#

		def self.time_in_seconds(t)
			time = t.to_s.split(':')
			minutes = time[0].to_i
			seconds = time[1].to_i

			return (minutes * 60) + seconds
		end

		#
		# UPDATE FUNCTIONS
		#

		def self.merge_games(time)
			# Collect All Games Created
			games = Game.where("created_at >= ? OR updated_at >= ?", time.utc, time.utc)
			Team.update_teams(games, time)
			Skater.update_skaters(games, time)
			Goalie.update_goalies(games, time)
		end
end
