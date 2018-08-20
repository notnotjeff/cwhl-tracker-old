class SkatersController < ApplicationController
	helper_method :sort_column, :sort_direction

  def index
    # Set And Error Check Filter Params
    @situation = set_situation(params[:situation].to_s, params[:report].to_s)
    @min_games_played = set_games_played(params[:min_games_played].to_i)
    @page = set_page(params[:page].to_i)
    @rookie = set_rookie(params[:rookie].to_i)
    @low_age = set_low_age(params[:min_age].to_i)
    @high_age = set_high_age(params[:max_age].to_i)
    @exempt_zero_ages = set_exempt_zero_ages(params[:no_age].to_i)
		@year_start, @year_end = set_season_range(params[:year_start].to_i, params[:year_end].to_i)
		@is_regular, @is_playoffs = set_season_type(params[:regular], params[:playoffs])
		@report = set_report(params[:report].to_s, @situation)
    @teams, @team_ids = set_teams(params[:teams])
    @selected_skaters = set_selected_skaters(params[:skater_select])
    @aggregate = set_aggregate(params[:aggregate].to_i)
		@season_range = @aggregate == 1 ? "#{@year_start.to_s[-2, 2]}-#{@year_end.to_s[-2, 2]}" : false
    # Filter Players Based On Params
    players_full = Skater.season_select(@year_start, @year_end, @is_regular, @is_playoffs)
													.position_select(params[:position])
													.teams_select(@teams)
													.age_range_select(@low_age, @high_age, @exempt_zero_ages)
													.select_handedness(params[:handedness])
													.rookie_select(@rookie)
                          .skater_select(@selected_skaters)
                          .order("#{sort_column} #{sort_direction}")
                          .aggregate_and_minimum_games(@aggregate, @min_games_played)

    @players = players_full.page(@page)

    respond_to do |format|
      format.html
      format.csv { render plain: players_full.to_csv }
			format.json { render json: players_full.to_json(:except => [:created_at, :updated_at, :fights, :fights_pg, :shots, :shots_pg]) }
			format.js
    end
  end

  def monthly_totals
    # Initialize Variables
    player_id = 2121 #params[:player_id]
    season_id = 43 #params[:season_id]
    month = 10 #params[:date][:month]
    stats = { goals: 0,
              a1: 0,
              a2: 0,
              shots: 0,
              ev_goals: 0,
              ev_a1: 0,
              ev_a2: 0,
              pp_goals: 0,
              pp_a1: 0,
              pp_a2: 0,
              sh_goals: 0,
              sh_a1: 0,
              sh_a2: 0,
              ps_goals: 0,
              points: 0,
              ev_points: 0,
              pp_points: 0,
              sh_points: 0 }

    # Find Player (Even If They Played On More Than One Team)
    players = Skater.where(player_id: player_id, season_id: season_id)

    # Cycle Through Both Players Filtering By Month And Add Their Stats For Selected Month
    players.each do |player|
      games = PlayerGameStatline.where('extract(month from game_date) = ? AND player_id = ? AND season_id = ?', month, player_id, season_id,)

      games.each do |game|
        puts game.goals
        stats[:goals] += game.goals
        stats[:a1] += game.a1
        stats[:a2] += game.a2
        stats[:shots] += game.shots
        stats[:ev_goals] += game.ev_goals
        stats[:ev_a1] += game.ev_a1
        stats[:ev_a2] += game.ev_a2
        stats[:pp_goals] += game.pp_goals
        stats[:pp_a1] += game.pp_a1
        stats[:pp_a2] += game.pp_a2
        stats[:sh_goals] += game.sh_goals
        stats[:sh_a1] += game.sh_a1
        stats[:sh_a2] += game.sh_a2
        stats[:ps_goals] += game.ps_goals
        stats[:points] += game.points
        stats[:ev_points] += game.ev_points
        stats[:pp_points] += game.pp_points
        stats[:sh_points] += game.sh_points
      end
    end

    render plain: stats
  end

  private
    def player_params
      params.require(:player).permit(:column, :direction, :situation, :position, :games_played, :page, :season)
    end

  	def sortable_columns
	    ["last_name", "goals", "a1", "a2", "games_played", "shots", "points", "pr_points", "position", "team_id", "goals_pg", "a1_pg", "a2_pg", "shots_pg", "points_pg", "pr_points_pg", "penalty_minutes", "penalty_minutes_pg", "ev_goals", "ev_a1", "ev_a2", "ev_goals_pg", "ev_a1_pg", "ev_a2_pg", "ev_points", "ev_points_pg", "ev_pr_points", "ev_pr_points_pg", "pp_goals", "pp_a1", "pp_a2", "pp_goals_pg", "pp_a1_pg", "pp_a2_pg", "pp_points", "pp_points_pg", "pp_pr_points", "pp_pr_points_pg", "sh_goals", "sh_a1", "sh_a2", "sh_goals_pg", "sh_a1_pg", "sh_a2_pg", "sh_points", "sh_points_pg", "sh_pr_points", "sh_pr_points_pg", "shooting_percent", "season_age", "shootout_attempts", "shootout_percent", "shootout_goals", "shootout_game_winners", "ps_taken", "ps_goals", "ps_percent", "gf_es", "ga_es", "gf_p_es", "gf_pp", "ga_pp", "gf_p_pp", "gf_pk", "ga_pk", "gf_p_pk", "gf_5v5", "ga_5v5", "gf_p_5v5", "gf_4v4", "ga_4v4", "gf_p_4v4", "gf_3v3", "ga_3v3", "gf_p_3v3", "gf_6v5", "ga_6v5", "gf_p_6v5", "gf_6v4", "ga_6v4", "gf_p_6v4", "gf_6v3", "ga_6v3", "gf_p_6v3", "gf_5v4", "ga_5v4", "gf_p_5v4", "gf_5v3", "ga_5v3", "gf_p_5v3", "gf_4v3", "ga_4v3", "gf_p_4v3", "gf_5v6", "ga_5v6", "gf_p_5v6", "gf_4v6", "ga_4v6", "gf_p_4v6", "gf_3v6", "ga_3v6", "gf_p_3v6", "gf_4v5", "ga_4v5", "gf_p_4v5", "gf_3v5", "ga_3v5", "gf_p_3v5", "gf_3v4", "ga_3v4", "gf_p_3v4", "gf_enf", "ga_enf", "gf_p_enf", "gf_ena", "ga_ena", "gf_p_ena", "en_goals", "en_a1", "en_a2", "en_points", "shoots", "season_id", "gf_es_pg", "ga_es_pg", "gf_pp_pg", "ga_pp_pg", "gf_pk_pg", "ga_pk_pg", "gf_es_rel", "gf_pp_rel", "gf_pk_rel", "gf_5v5_rel", "as_ipp", "es_ipp", "pp_ipp", "minors", "minors_pg", "double_minors", "double_minors_pg", "majors", "majors_pg", "fights", "fights_pg", "misconducts", "misconducts_pg", "game_misconducts", "game_misconducts_pg"]
	  end

	  def sort_column
	    sortable_columns.include?(params[:column]) ? params[:column] : "points"
	  end

	  def sort_direction
	    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
	  end

    def set_situation(sit, rep)
      sit = "All Situations" if (sit != "All Situations" && sit != "Even Strength" && sit != "Powerplay" && sit != "Shorthanded" && sit != "Penalty Shot" && sit != "Shootout" && sit != "Empty Net") || rep == "Penalty Breakdown"
      return sit
    end

		def set_report(r, sit)
      r = "Scoring" if (r != "Scoring" && r != "On Ice Breakdown" && r != "Penalty Breakdown") || sit == "Penalty Shot" || sit == "Shootout"
      return r
    end

    def set_page(page)
      if page < 1
        page = 1
      end
      return page
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

    def set_rookie(rookie)
      if rookie == 1
        rookie = true
      else
        rookie = false
      end
      return rookie
    end

    def set_exempt_zero_ages(no_age)
      if no_age == 1
        return true
      else
        return false
      end
    end

    def set_low_age(low_age)
      if low_age == nil || low_age < 18 || low_age > 50
        low_age = 18
        params[:low_age_range] = 18
      end
      return low_age
    end

    def set_high_age(high_age)
      if high_age == nil || high_age < 18 || high_age > 50
        high_age = 50
        params[:high_age_range] = 50
      end
      return high_age
    end

    def set_aggregate(aggregation_type)
      return [0, 1, 2].include?(aggregation_type) ? aggregation_type : 0
    end

    def set_is_regular(is_regular)
      if is_regular == nil
        is_regular = true
      elsif is_regular == "false"
        is_regular = false
      else
        is_regular = true
      end
      return is_regular
    end

    def set_is_playoffs(is_playoffs)
      if is_playoffs == "true"
        is_playoffs = true
      else
        is_playoffs = false
      end
    end

    def set_games_played(games)
      if games < 0 || games.nil?
        return 0
      else
        return games
      end
    end

		def set_selected_skaters(skaters)
			return skaters = [] if skaters.nil?
			return skaters.map(&:to_i)
		end

		def set_teams(teams)
      return nil if teams.nil?
      teams_arr = Team.where(id: teams.map(&:to_i)).pluck(:abbreviation, :team_code)
			return teams_arr, teams.map(&:to_i)
		end
end
