class GoaliesController < ApplicationController
  helper_method :sort_column, :sort_direction

  def index
    # Set And Error Check Filter Params
    @page = set_page(params[:page].to_i)
    @min_games_played = set_games_played(params[:min_games_played].to_i)
    @shots_against = set_shots_against(params[:shots_against].to_i)
    @rookie = set_rookie(params[:rookie].to_i)
    @low_age = set_low_age(params[:min_age].to_i)
    @high_age = set_high_age(params[:max_age].to_i)
    @year_start, @year_end = set_season_range(params[:year_start].to_i, params[:year_end].to_i)
    @is_regular, @is_playoffs = set_season_type(params[:regular], params[:playoffs])
    @goalie_report = set_goalie_report(params[:goalie_report].to_s)
    @teams, @team_ids = set_teams(params[:teams])
    @selected_goalies = set_selected_goalies(params[:goalie_select])
    @aggregate = set_aggregate(params[:aggregate].to_i)
    @season_range = @aggregate == 1 ? "#{@year_start.to_s[-2, 2]}-#{@year_end.to_s[-2, 2]}" : false

    goalies_full = Goalie.all.season_select(@year_start, @year_end, @is_regular, @is_playoffs)
                              .minimum_shots_against(@shots_against)
                              .teams_select(@teams)
                              .age_range_select(@low_age, @high_age)
                              .rookie_select(@rookie)
    													.goalie_select(@selected_goalies)
                              .order("#{sort_column} #{sort_direction}")
                              .aggregate_and_minimum_games(@aggregate, @min_games_played)

    @goalies = goalies_full.page(@page)

    respond_to do |format|
      format.html
      format.csv { render plain: goalies_full.to_csv }
      format.json { render json: goalies_full }
      format.js
    end
  end

	private
		def sortable_columns
		    ["last_name", "goals", "assists", "games_played", "shots_against", "points", "saves", "position", "team_id", "goals_against", "shootout_attempts", "shootout_goals_against", "penalty_shot_attempts", "penalty_shot_goals_against", "shots_against_pg", "penalty_minutes", "penalties", "goals_against_average", "save_percentage", "shootout_percent", "saves_pg", "season_age", "season_id"]
	  end

	  def sort_column
	    sortable_columns.include?(params[:column]) ? params[:column] : "saves"
	  end

	  def sort_direction
	    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
	  end

    def set_situation(sit)
      sit ||= "All Situations"
      return sit
    end

    def set_page(page)
      if page < 1
        page = 1
      end
      return page
    end

    def set_rookie(rookie)
      if rookie == 1
        rookie = true
      else
        rookie = false
      end
      return rookie
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

    def set_seasons(seasons)
      return [Season.current_season_id] if seasons.nil?
      return [0] if seasons.include?("0")
			return seasons.map(&:to_i)
    end

    def set_goalie_report(table_type)
      if table_type != "Shootout/Penalty Shot"
        return "Regulation"
      else
        return table_type
      end
    end

    def set_games_played(games)
      if games < 0 || games.nil?
        return 0
      else
        return games
      end
    end

    def set_shots_against(shots)
      if shots < 0 || shots.nil?
        return 0
      else
        return shots
      end
    end

    def set_selected_goalies(goalies)
			return goalies = [] if goalies.nil?
			return goalies.map(&:to_i)
		end

		def set_teams(teams)
      return nil if teams.nil?
      teams_arr = Team.where(id: teams.map(&:to_i)).pluck(:abbreviation, :team_code)
			return teams_arr, teams.map(&:to_i)
    end
    
    def set_aggregate(aggregation_type)
      return [0, 1, 2].include?(aggregation_type) ? aggregation_type : 0
    end
end
