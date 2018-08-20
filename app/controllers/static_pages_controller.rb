class StaticPagesController < ApplicationController
	def home
		current_season = Season.find_by(current_season: true)
		@primary_leaders = Skater.where('games_played > 5 AND season_id = ?', current_season.cwhl_id).order(pr_points_pg: :desc).limit(5)
		@points_leaders = Skater.where('games_played > 5 AND season_id = ?', current_season.cwhl_id).limit(5).order(points_pg: :desc)
		@save_percent_leaders = Goalie.where('games_played > 5 AND season_id = ?', current_season.cwhl_id).where.not(save_percentage: 0.0/0).order(save_percentage: :desc).limit(5)
		@shots_against_leaders = Goalie.where('games_played > 5 AND season_id = ?', current_season.cwhl_id).order(shots_against_pg: :desc).limit(5)
	end

	def about
	end

	def search
		if params[:search_bar].to_s == ""
			@players = nil
			@teams = nil
		else
			@players = Player.name_finder(params[:search_bar]).order(last_name: :asc)
			@teams = Team.team_finder(params[:search_bar]).order(city: :asc)

			if @players.count == 1 && @teams.count == 0
				redirect_to @players.first
			elsif @players.count == 0 && @teams.count == 1
				redirect_to @teams.first
			end
		end
	end

end
