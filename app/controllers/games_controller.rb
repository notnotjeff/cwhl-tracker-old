class GamesController < ApplicationController
  def index
    @page = set_page(params[:page].to_i)
    @seasons = set_seasons(params[:seasons])
    @goals_scored = set_goals_scored(params[:goals_scored].to_i)
    @result = set_result(params[:result].to_s)
    @teams, @team_ids = set_teams(params[:teams])
    @only_selected = set_only_selected(params[:only_selected].to_s)

  	@games = Game.all.order(game_date: :desc).teams_select(@teams, @only_selected)
                                            .season_select(@seasons)
                                            .with_result(@result)
                                            .total_goals_scored(@goals_scored)
                                            .page(@page)
  end

  def show
  	@game = Game.find(params[:id])
  	@home_team = TeamStatline.find_by(team_code: @game.home_team_id, season_id: @game.season_id)
  	@visiting_team = TeamStatline.find_by(team_code: @game.visiting_team_id, season_id: @game.season_id)

  	@game_goals = @game.goals.order(game_time_elapsed: :asc)
    @penalty_shots = @game.penalty_shots

  	@home_skaters = PlayerGameStatline.where(game_id: @game.cwhl_game_id, team_id: @home_team.team_code, season_id: @game.season_id).order(number: :asc)
  	@visiting_skaters = PlayerGameStatline.where(game_id: @game.cwhl_game_id, team_id: @visiting_team.team_code, season_id: @game.season_id).order(number: :asc)

    @home_goalies = GoalieGameStatline.where(game_id: @game.cwhl_game_id, team_id: @home_team.team_code, season_id: @game.season_id).order(number: :asc)
    @visitor_goalies = GoalieGameStatline.where(game_id: @game.cwhl_game_id, team_id: @visiting_team.team_code, season_id: @game.season_id).order(number: :asc)

    if @game.shootout == true
      @home_shootout_attempts = ShootoutAttempt.where(game_id: @game.cwhl_game_id, season_id: @game.season_id, team_id: @game.home_team_id)
      @visitor_shootout_attempts = ShootoutAttempt.where(game_id: @game.cwhl_game_id, season_id: @game.season_id, team_id: @game.visiting_team_id)
    end

    @game_penalties = @game.penalties.order(game_time_elapsed: :asc)

    respond_to do |format|
      format.html
      format.json { render json: @game.to_json(:except => [:created_at, :updated_at], :methods => [:game_abbreviation, :ended_in, :home_name, :visitor_name, :home_total_shots, :visitor_total_shots], :include => [{:teams => {:except => [:created_at, :updated_at]}},
                                                                                                                                                                                                                    {:overtimes => {:except => [:created_at, :updated_at]}},
                                                                                                                                                                                                                    {:penalty_shots => {:except => [:created_at, :updated_at]}},
                                                                                                                                                                                                                    {:shootout_attempts => {:except => [:created_at, :updated_at]}},
                                                                                                                                                                                                                    {:skaters => {:except => [:created_at, :updated_at]}},
                                                                                                                                                                                                                    {:goalies => {:except => [:created_at, :updated_at]}},
                                                                                                                                                                                                                    {:coaches => {:except => [:created_at, :updated_at]}},
                                                                                                                                                                                                                    {:referees => {:except => [:created_at, :updated_at]}},
                                                                                                                                                                                                                    {:stars => {:except => [:created_at, :updated_at]}},
                                                                                                                                                                                                                    {:penalties => {:except => [:created_at, :updated_at]}},
                                                                                                                                                                                                                    {:goals => {:include => [{:on_ice_skaters => {:except => [:created_at, :updated_at]}}], :except => [:created_at, :updated_at]}}]
                                                                                                                                                                                                                    ) }
    end
  end

  private
    def set_page(page)
      if page < 1
        page = 1
      end
      return page
    end

    def set_game_ids(game_ids)
      return nil if game_ids.nil?
      return game_ids.map(&:to_i)
    end

    def set_teams(teams)
      return nil if teams.nil?
      teams_arr = Team.where(id: teams.map(&:to_i)).pluck(:abbreviation, :team_code)
			return teams_arr, teams.map(&:to_i)
		end

    def set_seasons(seasons)
      return [Season.current_season_id] if seasons.nil?
			return [0] if seasons.include?("0")
			return seasons.map(&:to_i)
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

    def set_result(result)
      result = "Any" unless result == "Overtime" || result == "Shootout" || result == "Regulation" || result == "OT & SO"
      return result
    end

    def set_goals_scored(gs)
      gs = 0 unless gs > 0 && gs <= 25
      return gs
    end

    def set_only_selected(os)
      os = os == "true" ? true : false
      return os
    end
end
