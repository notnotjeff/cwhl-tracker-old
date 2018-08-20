class TeamsController < ApplicationController
	helper_method :sort_column, :sort_direction
	helper_method :profile_sort_column, :profile_sort_direction
	helper_method :game_sort_column, :game_sort_direction
	helper_method :penalty_sort_column, :penalty_sort_direction

	def index
    @page = set_page(params[:page].to_i)
		@year_start, @year_end = set_season_range(params[:year_start].to_i, params[:year_end].to_i)
		@is_regular, @is_playoffs = set_season_type(params[:regular], params[:playoffs])
    @category = set_category(params[:category])
		@selected_teams, @team_ids = set_teams(params[:teams])
		@aggregate = set_aggregation(params[:aggregate].to_i)
		@season_range = @aggregate == true ? "#{@year_start.to_s[-2, 2]}-#{@year_end.to_s[-2, 2]}" : false

  	teams_full = TeamStatline.all.order("#{sort_column} #{sort_direction}")
																	.teams_select(@selected_teams)
																	.season_select(@year_start, @year_end, @is_regular, @is_playoffs)
																	.aggregate(@aggregate)
		
		@teams = teams_full.page(@page)

    respond_to do |format|
      format.html
      format.csv { render plain: teams_full.to_csv }
			format.json { render json: teams_full }
			format.js
    end
  end

  def show
		@team = Team.find(params[:id])
		@season = false
		@season_ids, @is_regular, @is_playoffs = set_season_filter(params[:regular].to_s, params[:playoffs].to_s)
    @seasons = TeamStatline.where(season_id: @season_ids, team_code: @team.team_code).order("#{profile_sort_column} #{profile_sort_direction}")
		@games_season = set_season(params[:season].to_i, @team)
		@category = set_category(params[:category])
		@page = 1

		@games = TeamGameStatline.where(team_id: @team.team_code, season_id: @games_season[1]).order("#{game_sort_column} #{game_sort_direction}")
		
		respond_to do |format|
      format.html
			format.js
			format.json { render json: @seasons.to_json(:except => [:created_at, :updated_at], :methods => [:season]) }
    end
  end

	def roster
		@team = Team.find(params[:id])
		@season = set_season(params[:season], @team)
		@seasons = TeamStatline.where(team_code: @team.team_code).order(season_id: :desc)
		@skaters = Skater.where(team_id: @team.team_code, season_id: @season[1]).order(number: :asc)
		@goalies = Goalie.where(team_id: @team.team_code, season_id: @season[1]).order(number: :asc)

		@seasons.each do |season|
			@seasons_for_option = @seasons_for_option.nil? ? @seasons_for_option = [[season.season, season.season_id]] : @seasons_for_option << [season.season, season.season_id]
		end
	end

	def penalties
		@team = Team.find(params[:id])
		@season = set_season(params[:season], @team)
		@seasons = TeamStatline.where(team_code: @team.team_code).order(season_id: :desc)
		@penalties = Penalty.where(season_id: @season[1], team_id: @team.team_code).order("#{penalty_sort_column} #{penalty_sort_direction}")

		@seasons.each do |season|
			@seasons_for_option = @seasons_for_option.nil? ? @seasons_for_option = [[season.season, season.season_id]] : @seasons_for_option << [season.season, season.season_id]
		end

		respond_to do |format|
      format.html
			format.js
    end
	end

  private
		def set_season(season_id, team)
			if season_id.nil? || season_id == 0 || TeamStatline.where(team_code: team.team_code, season_id: season_id).count == 0
				season_id = TeamStatline.where(team_code: team.team_code).order(season_id: :desc).first.season_id
			end

			season = Season.find_by(cwhl_id: season_id)

			return [season.abbreviation, season_id]
		end

  	def sortable_columns
		  [
				"games_played", 
				"wins", 
				"losses", 
				"ot_losses", 
				"so_losses", 
				"forfeit_wins",
				"forfeit_losses",
				"points", 
				"points_percentage", 
				"row", 
				"penalty_minutes", 
				"goals_for", 
				"goals_against", 
				"ev_goals_for", 
				"ev_goals_against", 
				"pp_goals_for", 
				"pp_goals_against", 
				"sh_goals_for", 
				"sh_goals_against", 
				"first_period_shots", 
				"second_period_shots", 
				"third_period_shots", 
				"ot_shots", 
				"shots", 
				"shots_against", 
				"shots_against_pg", 
				"shots_pg", 
				"shots_percent", 
				"so_wins", 
				"ot_wins", 
				"first_period_shots_pg", 
				"second_period_shots_pg", 
				"third_period_shots_pg", 
				"ot_period_shots_pg", 
				"goals_against_pg", 
				"goals_for_pg", 
				"ev_goals_for_pg", 
				"ev_goals_against_pg", 
				"pp_goals_for_pg", 
				"pp_goals_against_pg", 
				"sh_goals_for_pg", 
				"sh_goals_against_pg", 
				"first_period_goals_pg", 
				"second_period_goals_pg", 
				"third_period_goals_pg", 
				"ot_period_goals_pg", 
				"shootout_attempts", 
				"shootout_goals", 
				"shootout_percent", 
				"city", 
				"season_id", 
				"pdo", 
				"ev_goals_percent", 
				"goals_percent", 
				"shooting_percent", 
				"save_percent", 
				"gf_6v5", 
				"ga_6v5", 
				"gf_5v6", 
				"ga_5v6",
				"gf_5v5", 
				"ga_5v5", 
				"gf_p_5v5", 
				"gf_5v4", 
				"ga_5v4", 
				"gf_4v5", 
				"ga_4v5", 
				"gf_4v4", 
				"ga_4v4", 
				"gf_p_4v4", 
				"gf_4v3", 
				"ga_4v3", 
				"gf_3v4", 
				"ga_3v4", 
				"gf_3v3", 
				"ga_3v3", 
				"gf_p_3v3", 
				"gf_5v3", 
				"ga_5v3", 
				"gf_3v5", 
				"ga_3v5", 
				"gf_6v3", 
				"ga_6v3", 
				"gf_3v6", 
				"ga_3v6", 
				"gf_6v4", 
				"ga_6v4", 
				"gf_4v6", 
				"ga_4v6",
				"ot_period_goals", 
				"minors",
				"minors_pg",
				"double_minors", 
				"double_minors_pg", 
				"majors", 
				"majors_pg", 
				"fights", 
				"fights_pg",
				"misconducts",
				"misconducts_pg", 
				"game_misconducts", 
				"game_misconducts_pg"
			]
	  end

	  def sort_column
	    sortable_columns.include?(params[:column]) ? params[:column] : "points_percentage"
	  end

	  def sort_direction
	    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
	  end

		def profile_sortable_columns
			["games_played", "wins", "losses", "ot_losses", "so_losses", "points", "points_percentage", "row", "penalty_minutes", "goals_for", "goals_against", "ev_goals_for", "ev_goals_against", "pp_goals_for", "pp_goals_against", "sh_goals_for", "sh_goals_against", "first_period_shots", "second_period_shots", "third_period_shots", "ot_shots", "shots", "shots_against", "shots_against_pg", "shots_pg", "shots_percent", "so_wins", "ot_wins", "first_period_shots_pg", "second_period_shots_pg", "third_period_shots_pg", "ot_period_shots_pg", "goals_against_pg", "goals_for_pg", "ev_goals_for_pg", "ev_goals_against_pg", "pp_goals_for_pg", "pp_goals_against_pg", "sh_goals_for_pg", "sh_goals_against_pg", "first_period_goals_pg", "second_period_goals_pg", "third_period_goals_pg", "ot_period_goals_pg", "shootout_attempts", "shootout_goals", "shootout_percent", "city", "season_id", "pdo", "ev_goals_percent", "goals_percent", "shooting_percent", "save_percent", "gf_6v5", "ga_6v5", "gf_5v6", "ga_5v6", "gf_5v5", "ga_5v5", "gf_p_5v5", "gf_5v4", "ga_5v4", "gf_4v5", "ga_4v5", "gf_4v4", "ga_4v4", "gf_p_4v4", "gf_4v3", "ga_4v3", "gf_3v4", "ga_3v4", "gf_3v3", "ga_3v3", "gf_p_3v3", "gf_5v3", "ga_5v3", "gf_3v5", "ga_3v5", "gf_6v3", "ga_6v3", "gf_3v6", "ga_3v6", "gf_6v4", "ga_6v4", "gf_4v6", "ga_4v6", "ot_period_goals"]
		end

	  def profile_sort_column
	    profile_sortable_columns.include?(params[:profile_sort_column]) ? params[:profile_sort_column] : "season_id"
	  end

	  def profile_sort_direction
	    %w[asc desc].include?(params[:profile_sort_direction]) ? params[:profile_sort_direction] : "desc"
	  end

		def game_sortable_columns
		  ["game_date", "opponent_abbreviation", "won", "shots_for", "shots_against", "goals_for", "goals_against", "ev_goals", "ev_goals_against"]
	  end

	  def game_sort_column
	    game_sortable_columns.include?(params[:game_sort_column]) ? params[:game_sort_column] : "game_date"
	  end

	  def game_sort_direction
	    %w[asc desc].include?(params[:game_sort_direction]) ? params[:game_sort_direction] : "desc"
	  end

		def penalty_sortable_columns
		  ["game_date", "game_name", "description", "duration", "player_id"]
	  end

		def penalty_sort_column
	    penalty_sortable_columns.include?(params[:penalty_sort_column]) ? params[:penalty_sort_column] : "game_date"
		end

		def penalty_sort_direction
	    %w[asc desc].include?(params[:penalty_sort_direction]) ? params[:penalty_sort_direction] : "desc"
		end
		
		def set_season_range(start_year, end_year)
			valid_start_years = Season.pluck(:year_start).uniq
			valid_end_years = Season.pluck(:year_end).uniq

			start_year = valid_start_years.include?(start_year) ? start_year : Season.current_season_start
			end_year = valid_end_years.include?(end_year) ? end_year : Season.current_season_end

			return start_year, end_year
		end

		def set_season_type(is_regular, is_playoffs)
			is_playoffs = is_playoffs == "true" ? true : false
			is_regular = is_regular == "true" ? true : false

			is_regular = true if is_regular == false && is_playoffs == false

			return is_regular, is_playoffs
		end

    def set_category(category)
      if TeamStatline.stat_categories.include? (category)
        return category
      else
        return "Game Stats"
      end
    end

    def set_page(page)
      if page < 1
        page = 1
      end
      return page
    end

		def set_seasons(seasons)
      return [Season.current_season_id] if seasons.nil?
			return [0] if seasons.include?("0") || (seasons.include?("-1") && seasons.include?("-2"))
			return [-1] if seasons.include?("-1")
			return [-2] if seasons.include?("-2")
			return seasons.map(&:to_i)
    end

		def set_teams(teams)
      return nil if teams.nil?
      teams_arr = Team.where(id: teams.map(&:to_i)).pluck(:abbreviation, :team_code)
			return teams_arr, teams.map(&:to_i)
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

		def set_aggregation(aggregation_choice)
			return aggregation_choice == 1 ? true : false
		end
end
