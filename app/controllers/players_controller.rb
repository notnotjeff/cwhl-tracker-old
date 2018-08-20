class PlayersController < ApplicationController
	helper_method :sort_column, :sort_direction
	helper_method :game_sort_column, :game_sort_direction
	helper_method :ob_column, :ob_direction
	helper_method :penalty_sort_column, :penalty_sort_direction
	helper_method :on_ice_sort_column, :on_ice_sort_direction

	before_action :check_position, only: [:goal_breakdown, :monthly_breakdown, :linemates, :opposition_breakdown]

	def show
		@player = Player.find(params[:id])
		@season_games = set_season_games(params[:season].to_i, @player)
		@situation = set_situation(params[:situation].to_s, params[:report].to_s)
		@goalie_report = set_goalie_report(params[:goalie_report].to_s)
		@report = set_report(params[:report].to_s, @situation)
		season_ids, @is_regular, @is_playoffs = set_season_filter(params[:regular].to_s, params[:playoffs].to_s)
		@page = 1

		if @player.position == "G"
			@statlines = Goalie.where(season_id: season_ids, player_id: @player.cwhl_id).order("#{sort_column} #{sort_direction}")
			@games = GoalieGameStatline.where('player_id = ? AND season_id = ? AND time_on_ice > 0', @player.cwhl_id, @season_games[1]).order("#{game_sort_column} #{game_sort_direction}")
			@seasons = Goalie.where(player_id: @player.cwhl_id).order("#{sort_column} #{sort_direction}")
		else
			@statlines = Skater.where(season_id: season_ids, player_id: @player.cwhl_id).order("#{sort_column} #{sort_direction}")
			@games = PlayerGameStatline.where(player_id: @player.cwhl_id, season_id: @season_games[1]).order("#{game_sort_column} #{game_sort_direction}")
			@seasons = @player.seasons.order("#{sort_column} #{sort_direction}")
		end

		@on_ice_events = OnIceSkater.where(season_id: @season_games[1], player_id: @player.cwhl_id).order("#{on_ice_sort_column} #{on_ice_sort_direction}")
		@penalties = Penalty.where(player_id: @player.cwhl_id, season_id: @season_games[1]).order("#{penalty_sort_column} #{penalty_sort_direction}")

		@seasons.each do |season|
			@seasons_for_option = @seasons_for_option.nil? ? @seasons_for_option = [["#{season.season_abbreviation} #{season.team_abbreviation}", season.season_id]] : @seasons_for_option << ["#{season.season_abbreviation} #{season.team_abbreviation}", season.season_id]
		end

		# Order Options By Year (Descending)
		@seasons_for_option.sort! { |a, b| b[1] <=> a[1] }

		respond_to do |format|
      		format.html
			format.js
			format.json { render json: @statlines.to_json(:except => [:created_at, :updated_at], :methods => [:season]) }
    	end
	end

	def index
		players = Player.all
		respond_to do |format|
			format.csv { render plain: players.to_csv }
	 	 end
	end

	def goal_breakdown
		@player = Player.find(params[:id])
		@seasons = []
		Skater.where(player_id: @player.cwhl_id).order(season_id: :desc).each do |year|
			@seasons << ["#{year.season_abbreviation} #{year.team_abbreviation}", year.id]
		end
		@team = set_team(params[:team].to_i, @seasons.map { |a, b| b })
		season = Skater.find(@team)

		@teammates = Skater.where(season_id: season.season_id, team_id: season.team_id).where.not(player_id: season.player_id).order(position: :asc)
		@linemates = params[:linemates] != nil && params[:linemates] != "" ? set_linemates(params[:linemates].map! { |i| i.to_i }, @teammates.pluck(:player_id)) : []
		@linemates_string = set_linemates_string(@linemates)

		if @linemates != []
			oig = OnIceSkater.where('season_id = ? AND player_id = ? AND team_id = ? AND teammate_count > ? AND opposing_skaters_count > ?', season.season_id, season.player_id, season.team_id, 2, 2).pluck(:goal_id)
			linemate_oig = []

			player_ids = []
			player_ids = @linemates if @linemates.count > 0

			player_ids.each do |player_id|
				linemate_oig = OnIceSkater.where('season_id = ? AND player_id = ? AND team_id = ? AND teammate_count > ? AND opposing_skaters_count > ?', season.season_id, player_id, season.team_id, 2, 2).pluck(:goal_id)
				off_ice_goal_ids = oig - linemate_oig
				oig = oig - off_ice_goal_ids
			end

			@goals = Goal.where(id: oig)
			@gf = @goals.where(team_id: season.team_id)
			@ga = @goals.where(opposing_team_id: season.team_id)
		else
			oig = OnIceSkater.where('season_id = ? AND player_id = ? AND team_id = ? AND teammate_count > ? AND opposing_skaters_count > ?', season.season_id, season.player_id, season.team_id, 2, 2).pluck(:goal_id)
			@goals = Goal.where(id: oig)
			@gf = @goals.where(team_id: season.team_id)
			@ga = @goals.where(opposing_team_id: season.team_id)
		end

		@ev_gf = @gf.where(is_powerplay: false, is_empty_net: false, is_shorthanded: false, is_penalty_shot: false, team_player_count: 5, opposing_team_player_count: 5)
											.or(@gf.where(is_powerplay: false, is_empty_net: false, is_shorthanded: false, is_penalty_shot: false, team_player_count: 4, opposing_team_player_count: 4))
											.or(@gf.where(is_powerplay: false, is_empty_net: false, is_shorthanded: false, is_penalty_shot: false, team_player_count: 3, opposing_team_player_count: 3))
											.count
		@ev_ga = @ga.where(is_powerplay: false, is_empty_net: false, is_shorthanded: false, is_penalty_shot: false, team_player_count: 5, opposing_team_player_count: 5)
											.or(@ga.where(is_powerplay: false, is_empty_net: false, is_shorthanded: false, is_penalty_shot: false, team_player_count: 4, opposing_team_player_count: 4))
											.or(@ga.where(is_powerplay: false, is_empty_net: false, is_shorthanded: false, is_penalty_shot: false, team_player_count: 3, opposing_team_player_count: 3))
											.count

		@pp_gf = @gf.where(is_powerplay: true, is_empty_net: false).count
		@pp_ga = @ga.where(is_shorthanded: true, is_empty_net: false).count

		@sh_gf = @gf.where(is_shorthanded: true, is_empty_net: false).count
		@sh_ga = @ga.where(is_powerplay: true, is_empty_net: false).count

		@en_a_gf = @gf.where(is_empty_net: true).count
		@en_f_ga = @ga.where(is_empty_net: true, opposing_team_id: season.team_id).count

		@en_a_ga = @ga.count - @pp_ga - @sh_ga - @ev_ga - @en_f_ga
		@en_f_gf = @gf.count - @pp_gf - @sh_gf - @ev_gf - @en_a_gf

		respond_to do |format|
      		format.html
			format.js
    	end
	end

	def monthly_breakdown
		@player = Player.find(params[:id])
		@seasons = []
		@months = {}
		
		Skater.where(player_id: @player.cwhl_id).order(season_id: :desc).each do |year|
			@seasons << ["#{year.season_abbreviation} #{year.team_abbreviation}", year.id]
		end
		@team = set_team(params[:team].to_i, @seasons.map { |a, b| b })
		season = Skater.find(@team)

		if season.season_abbreviation.include?('PO')
			@months[:MAR] = get_skater_monthly_stats(3, season.season_id, @player.cwhl_id, season.team_id)
		else
			@months[:OCT] = get_skater_monthly_stats(10, season.season_id, @player.cwhl_id, season.team_id)
			@months[:NOV] = get_skater_monthly_stats(11, season.season_id, @player.cwhl_id, season.team_id)
			@months[:DEC] = get_skater_monthly_stats(12, season.season_id, @player.cwhl_id, season.team_id)
			@months[:JAN] = get_skater_monthly_stats(1, season.season_id, @player.cwhl_id, season.team_id)
			@months[:FEB] = get_skater_monthly_stats(2, season.season_id, @player.cwhl_id, season.team_id)
			@months[:MAR] = get_skater_monthly_stats(3, season.season_id, @player.cwhl_id, season.team_id)
		end
	end

	def linemates
		@player = Player.find(params[:id])
		@seasons = []
		@months = {}
		@linemates = {}
		@situation = set_lineup_situation(params[:situation])
		@position, position_array = set_lineup_position(params[:position])
		
		Skater.where(player_id: @player.cwhl_id).order(season_id: :desc).each do |year|
			@seasons << ["#{year.season_abbreviation} #{year.team_abbreviation}", year.id]
		end
		@team = set_team(params[:team].to_i, @seasons.map { |a, b| b })
		season = Skater.find(@team)

		if @situation == "All Situations"
			player_goals = OnIceSkater.where(season_id: season.season_id, player_id: @player.cwhl_id, team_id: season.team_id).pluck(:goal_id)
		elsif @situation == "Even Strength"
			player_goals = OnIceSkater.where(season_id: season.season_id, player_id: @player.cwhl_id, team_id: season.team_id, teammate_count: 5, opposing_skaters_count: 5)
																.or(OnIceSkater.where(season_id: season.season_id, player_id: @player.cwhl_id, team_id: season.team_id, teammate_count: 4, opposing_skaters_count: 4))
																.or(OnIceSkater.where(season_id: season.season_id, player_id: @player.cwhl_id, team_id: season.team_id, teammate_count: 3, opposing_skaters_count: 3))
																.pluck(:goal_id)
		elsif @situation == "Powerplay"
			player_goals = OnIceSkater.where(season_id: season.season_id, player_id: @player.cwhl_id, team_id: season.team_id, is_powerplay: true).pluck(:goal_id)
		elsif @situation == "Shorthanded"
			player_goals = OnIceSkater.where(season_id: season.season_id, player_id: @player.cwhl_id, team_id: season.team_id, is_shorthanded: true).pluck(:goal_id)
		end

		total_goal_events = player_goals.count
		linemate_event_counts = OnIceSkater.where(goal_id: player_goals, team_id: season.team_id).where.not(player_id: @player.cwhl_id).group(:player_id).order('count_all desc').count
		
		linemate_event_counts.each do |linemate, count|
			player_info = Player.find(linemate)
			icetime_percent = (BigDecimal.new(count) / BigDecimal.new(total_goal_events)).round(3) * 100
			next unless position_array.include?(player_info.position)

			@linemates[linemate] = {
				name: "#{player_info.first_name} #{player_info.last_name}",
				position: player_info.position,
				goal_events: count,
				icetime_percent: icetime_percent
			}
		end
	end

	def opposition_breakdown
		@player = Player.find(params[:id])
		seasons = Skater.where(player_id: @player.id).order(season_id: :desc)
		@seasons_for_option = seasons.pluck(:season_abbreviation, :team_abbreviation, :id).map { |a, b, c| ["#{a} #{b}", c] }
		@seasons_for_option << ["Career", 0]
		@team = set_ob_team(params[:team].to_i, @seasons_for_option.map { |a, b| b })
		season = set_opposition_breakdown_season(@team)

		if season == 0
			where_statement = "player_id = #{@player.id}"
			group_statement = "player_id, opposing_team_id"
			season_statement = "MAX(season_id) AS season_id,"
		else
			where_statement = "player_id = #{@player.id} AND season_id = #{season.season_id}"
			group_statement = "player_id, opposing_team_id, season_id"
			season_statement = " season_id AS season_id,"
		end

		@teams = PlayerGameStatline.where(where_statement)
									.group(group_statement)
									.select("player_id AS player_id,
											#{season_statement}
											MAX(opposing_team_id) AS opposing_team_id,
											COUNT(opposing_team_id) AS games_played,
											SUM(goals) AS goals,
											SUM(a1) AS a1,
											SUM(a2) AS a2,
											SUM(points) AS points,
											SUM(shots) AS shots,
											ROUND(CAST(SUM(goals) AS DECIMAL) / COUNT(opposing_team_id), 2) AS goals_pg,
											ROUND(CAST(SUM(a1) AS DECIMAL) / COUNT(opposing_team_id), 2) AS a1_pg,
											ROUND(CAST(SUM(a2) AS DECIMAL) / COUNT(opposing_team_id), 2) AS a2_pg,
											ROUND(CAST(SUM(points) AS DECIMAL) / COUNT(opposing_team_id), 2) AS points_pg,
											ROUND(CAST(SUM(shots) AS DECIMAL) / COUNT(opposing_team_id), 2) AS shots_pg"
									).order("#{ob_column} #{ob_direction}")
					
		respond_to do |format|
			format.html
			format.js
		end
	end

	private

		def get_skater_monthly_stats(month, season_id, player_id, team_id)
			return PlayerGameStatline.where('season_id = ? AND team_id = ? AND player_id = ? AND EXTRACT(MONTH FROM game_date) = ?', season_id, team_id, player_id, month)
				.select("COUNT(DISTINCT game_id) AS games_played,
								SUM(player_game_statlines.goals) AS goals, 
								SUM(player_game_statlines.a1) AS a1, 
								SUM(player_game_statlines.a2) AS a2, 
								SUM(player_game_statlines.points) AS points, 
								SUM(player_game_statlines.ev_goals) AS ev_goals, 
								SUM(player_game_statlines.ev_a1) AS ev_a1, 
								SUM(player_game_statlines.ev_a2) AS ev_a2, 
								SUM(player_game_statlines.ev_points) AS ev_points, 
								SUM(player_game_statlines.pp_goals) AS pp_goals, 
								SUM(player_game_statlines.pp_a1) AS pp_a1, 
								SUM(player_game_statlines.pp_a2) AS pp_a2, 
								SUM(player_game_statlines.pp_points) AS pp_points, 
								SUM(player_game_statlines.sh_goals) AS sh_goals, 
								SUM(player_game_statlines.sh_a1) AS sh_a1, 
								SUM(player_game_statlines.sh_a2) AS sh_a2, 
								SUM(player_game_statlines.sh_points) AS sh_points, 
								SUM(player_game_statlines.ps_goals) AS ps_goals, 
								SUM(player_game_statlines.shots) AS shots,
								ROUND(AVG(player_game_statlines.goals), 2) AS goals_pg,
								ROUND(AVG(player_game_statlines.shots), 2) AS shots_pg,
								ROUND(AVG(player_game_statlines.a1), 2) AS a1_pg,
								ROUND(AVG(player_game_statlines.a2), 2) AS a2_pg,
								ROUND(AVG(player_game_statlines.points), 2) AS points_pg")[0]
		end

		def check_position
			redirect_to root_url if Player.find(params[:id].to_i).nil? || Player.find(params[:id].to_i).position == "G"
		end

		def set_lineup_situation(situation)
			situation = situation == "All Situations" || situation == "Even Strength" || situation == "Powerplay" || situation == "Shorthanded" ? situation : "All Situations"
		end

		def set_lineup_position(position)
			position = position == "Any" || position == "Forwards" || position == "Defensemen" ? position : "Any"

			if position == "Forwards"
				position_array = ["F", "LW", "RW", "C", "W"]
			elsif position == "Defensemen"
				position_array = ["D", "LD", "RD"]
			elsif position == "Any"
				position_array = ["F", "LW", "RW", "C", "W", "D", "LD", "RD"]
			end

			return position, position_array
		end

		def set_season_games(season_id, player)
			if player.position == "G"
				if season_id.nil? || season_id == 0 || Goalie.where(player_id: player.cwhl_id, season_id: season_id).count == 0
					season_id = Goalie.where(player_id: player.cwhl_id).order(season_id: :desc).first.season_id
				end
				season = Goalie.find_by(season_id: season_id, player_id: player.cwhl_id)
			else
				if season_id.nil? || season_id == 0 || Skater.where(player_id: player.cwhl_id, season_id: season_id).count == 0
					season_id = Skater.where(player_id: player.cwhl_id).order(season_id: :desc).first.season_id
				end
				season = Skater.find_by(season_id: season_id, player_id: player.cwhl_id)
			end

			return [season.season, season.season_id]
		end

  	def sortable_columns
		["last_name", "goals", "a1", "a2", "games_played", "shots", "points", "pr_points", "position", "team_id", "goals_pg", "a1_pg", "a2_pg", "shots_pg", "points_pg", "pr_points_pg", "penalty_minutes", "penalty_minutes_pg", "ev_goals", "ev_a1", "ev_a2", "ev_goals_pg", "ev_a1_pg", "ev_a2_pg", "ev_points", "ev_points_pg", "ev_pr_points", "ev_pr_points_pg", "pp_goals", "pp_a1", "pp_a2", "pp_goals_pg", "pp_a1_pg", "pp_a2_pg", "pp_points", "pp_points_pg", "pp_pr_points", "pp_pr_points_pg", "sh_goals", "sh_a1", "sh_a2", "sh_goals_pg", "sh_a1_pg", "sh_a2_pg", "sh_points", "sh_points_pg", "sh_pr_points", "sh_pr_points_pg", "shooting_percent", "season_age", "shootout_attempts", "shootout_percent", "shootout_goals", "shootout_game_winners", "ps_taken", "ps_goals", "ps_percent", "gf_es", "ga_es", "gf_p_es", "gf_pp", "ga_pp", "gf_p_pp", "gf_pk", "ga_pk", "gf_p_pk", "gf_5v5", "ga_5v5", "gf_p_5v5", "gf_4v4", "ga_4v4", "gf_p_4v4", "gf_3v3", "ga_3v3", "gf_p_3v3", "gf_6v5", "ga_6v5", "gf_p_6v5", "gf_6v4", "ga_6v4", "gf_p_6v4", "gf_6v3", "ga_6v3", "gf_p_6v3", "gf_5v4", "ga_5v4", "gf_p_5v4", "gf_5v3", "ga_5v3", "gf_p_5v3", "gf_4v3", "ga_4v3", "gf_p_4v3", "gf_5v6", "ga_5v6", "gf_p_5v6", "gf_4v6", "ga_4v6", "gf_p_4v6", "gf_3v6", "ga_3v6", "gf_p_3v6", "gf_4v5", "ga_4v5", "gf_p_4v5", "gf_3v5", "ga_3v5", "gf_p_3v5", "gf_3v4", "ga_3v4", "gf_p_3v4", "gf_enf", "ga_enf", "gf_p_enf", "gf_ena", "ga_ena", "gf_p_ena", "en_goals", "en_a1", "en_a2", "en_points", "shoots", "season_id", "gf_es_pg", "ga_es_pg", "gf_pp_pg", "ga_pp_pg", "gf_pk_pg", "ga_pk_pg", "gf_es_rel", "gf_pp_rel", "gf_pk_rel", "gf_5v5_rel",
		"goals_against", "shootout_attempts", "shootout_goals_against", "penalty_shot_attempts", "penalty_shot_goals_against", "shots_against_pg", "penalties", "goals_against_average", "save_percentage", "saves_pg", "saves", "shots_against", "assists", "as_ipp", "es_ipp", "pp_ipp", "minors", "minors_pg", "double_minors", "double_minors_pg", "majors", "majors_pg", "fights", "fights_pg", "misconducts", "misconducts_pg", "game_misconducts", "game_misconducts_pg"]
	end

	def sort_column
		sortable_columns.include?(params[:column]) ? params[:column] : "season_id"
	end

	def sort_direction
		%w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
	end

	def ob_column
		ob_sortable_columns.include?(params[:ob_column]) ? params[:ob_column] : "points"
	end

	def ob_direction
		%w[asc desc].include?(params[:ob_direction]) ? params[:ob_direction] : "desc"
	end

	def ob_sortable_columns
		["games_played", "goals", "a1", "a2", "points", "shots", "goals_pg", "shots_pg", "a1_pg", "a2_pg", "points_pg"]
	end

	# Separate Sortable Functions For Game Reports
	def game_sortable_columns
		["goals", "a1", "a2", "shots", "points", "game_id", "game_date", "shots_against", "goals_against", "saves", "time_on_ice", "save_percent", "game_name"]
	end

	def game_sort_column
		game_sortable_columns.include?(params[:game_column]) ? params[:game_column] : "game_date"
	end

	def game_sort_direction
		%w[asc desc].include?(params[:game_direction]) ? params[:game_direction] : "asc"
	end

	def penalty_sortable_columns
		["game_date", "game_name", "description", "duration", "player_id"]
	end

	def penalty_sort_column
		penalty_sortable_columns.include?(params[:penalty_column]) ? params[:penalty_column] : "game_date"
	end

	def penalty_sort_direction
		%w[asc desc].include?(params[:penalty_direction]) ? params[:penalty_direction] : "asc"
	end

	def on_ice_sort_column
		on_ice_sortable_columns.include?(params[:on_ice_column]) ? params[:on_ice_column] : "game_id"
	end

	def on_ice_sort_direction
		%w[asc desc].include?(params[:on_ice_direction]) ? params[:on_ice_direction] : "asc"
	end

	def on_ice_sortable_columns
		["game_id", "on_scoring_team", "teammate_count", "opposing_skaters_count", "period", "time", "game_date"]
	end

	def set_situation(sit, rep)
		sit = "All Situations" if (sit != "All Situations" && sit != "Even Strength" && sit != "Powerplay" && sit != "Shorthanded" && sit != "Penalty Shot" && sit != "Shootout" && sit != "Empty Net") || rep == "Penalty Breakdown"
		return sit
	end

	def set_report(r, sit)
		r = "Scoring" if (r != "Scoring" && r != "On Ice Breakdown" && r != "Penalty Breakdown") || sit == "Penalty Shot" || sit == "Shootout"
		return r
	end

	def set_goalie_report(table_type)
		if table_type != "Shootout/Penalty Shot" || table_type != "Shootout/Penalty Shot"
		return "Regulation"
		else
		return table_type
		end
	end

	def set_team(year, years)
		if years.include?(year)
			return year
		else
			return years[0]
		end
	end

	def set_ob_team(year, years)
		if years.include?(year) && year != nil
			return year
		else
			return years[0]
		end
	end

	def set_linemates(linemate_ids, teammate_ids)
		if linemate_ids.all? { |i| teammate_ids.include?(i) }
			return linemate_ids
		else
			return []
		end
	end

	def set_linemates_string(linemate_ids)
		string = "On Ice With: "
		string += "Any" if linemate_ids.count == 0

		linemate_ids.each_with_index do |l, i|
			string += Player.find_by(cwhl_id: l).full_name
			string += ", " unless i == linemate_ids.count - 1
		end
		return string
	end

	def set_season_filter(is_regular, is_playoffs)
		is_playoffs = is_playoffs == "true" ? true : false
		is_regular = is_regular == "true" ? true : false

		is_regular = true if is_regular == false && is_playoffs == false

		if is_playoffs == true && is_regular == true || is_playoffs == false && is_regular == false
			return Season.pluck(:cwhl_id), is_regular, is_playoffs
		elsif is_regular == true
			return Season.where(is_regular_season: true).pluck(:cwhl_id), is_regular, is_playoffs
		elsif is_playoffs == true
			return Season.where(is_playoffs: true).pluck(:cwhl_id), is_regular, is_playoffs
		end
	end

	def set_opposition_breakdown_season(team)
		if team == 0
			return 0
		else
			return Skater.find(team)
		end
	end
end
