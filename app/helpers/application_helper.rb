module ApplicationHelper
	def full_title(page_title = '')
		base_title = "CWHL Tracker"
		if page_title.empty?
			"#{base_title} | CWHL Statistics"
		else
			"#{base_title} | #{page_title}"
		end
	end

	def sort_link(path, column, title = nil)
		title ||= column.titleize
		if column != "last_name"
			direction = column == sort_column && sort_direction == "desc" ? "asc" : "desc"
		else
			direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
		end

		if path == "skaters"
    		highlighted = column == sort_column ? "active-link" : ""

			return link_to "#{title}".html_safe, skaters_path(	column: column,
																direction: direction,
																min_games_played: params[:min_games_played],
																report: params[:report],
																situation: params[:situation],
																position: params[:position],
																min_age: params[:min_age],
																max_age: params[:max_age],
																teams: params[:teams],
																handedness: params[:handedness],
																rookie: params[:rookie],
																no_age: params[:no_age],
																skater_select: params[:skater_select],
																year_start: params[:year_start],
																year_end: params[:year_end],
																regular: params[:regular],
																playoffs: params[:playoffs],
																aggregate: params[:aggregate]),
																{ class: "#{highlighted} sort-link", remote: true }

		elsif path == "goalies"
			highlighted = column == sort_column ? "active-link" : ""

			return link_to "#{title}".html_safe, goalies_path(
				column: column,
				direction: direction,
				min_games_played: params[:min_games_played],
				shots_against: params[:shots_against],
				position: params[:position],
				min_age_tag: params[:min_age],
				max_age_tag: params[:max_age],
				teams: params[:teams],
				rookie: params[:rookie],
				goalie_select: params[:goalie_select],
				goalie_report: params[:goalie_report],
				year_start: params[:year_start],
				year_end: params[:year_end],
				regular: params[:regular],
				playoffs: params[:playoffs],
				aggregate: params[:aggregate]),
			{ class: "#{highlighted} sort-link", remote: true }

		elsif path == "player"
    		highlighted = column == sort_column ? "active-link" : ""
			return link_to "#{title}".html_safe, player_path(@player.id,
				column: column,
				direction: direction,
				season: params[:season],
				game_column: params[:game_column],
				game_direction: params[:game_direction],
				on_ice_column: params[:on_ice_column],
				on_ice_direction: params[:on_ice_direction],
				penalty_column: params[:penalty_column],
				penalty_direction: params[:penalty_direction],
				situation: params[:situation],
				report: params[:report],
				goalie_report: params[:goalie_report],
				playoffs: params[:playoffs],
				regular: params[:regular]),
				{ class: "#{highlighted} sort-link", remote: true }

		elsif path == "player_game"
			if column != "last_name"
	    		direction = column == game_sort_column && game_sort_direction == "desc" ? "asc" : "desc"
			else
				direction = column == game_sort_column && game_sort_direction == "asc" ? "desc" : "asc"
			end

    		highlighted = column == game_sort_column ? "active-link" : ""

			return link_to "#{title}".html_safe, player_path(@player.id,
				game_column: column,
				game_direction: direction,
				column: params[:column],
				direction: params[:direction],
				on_ice_column: params[:on_ice_column],
				on_ice_direction: params[:on_ice_direction],
				penalty_column: params[:penalty_column],
				penalty_direction: params[:penalty_direction],
				season: params[:season],
				situation: params[:situation],
				report: params[:report],
				goalie_report: params[:goalie_report]),
				{ class: "#{highlighted} sort-link", remote: true }

		elsif path == "player_penalties"
			if column != "last_name"
	    	direction = column == penalty_sort_column && penalty_sort_direction == "desc" ? "asc" : "desc"
	    else
	    	direction = column == penalty_sort_column && penalty_sort_direction == "asc" ? "desc" : "asc"
	    end
    		highlighted = column == penalty_sort_column ? "active-link" : ""

			return link_to "#{title}".html_safe, player_path(@player.id,
				penalty_column: column,
				penalty_direction: direction,
				game_column: params[:game_column],
				game_direction: params[:game_direction],
				on_ice_column: params[:on_ice_column],
				on_ice_direction: params[:on_ice_direction],
				column: params[:column],
				direction: params[:direction],
				season: params[:season],
				situation: params[:situation],
				report: params[:report],
				goalie_report: params[:goalie_report]),
				{ class: "#{highlighted} sort-link", remote: true }

		elsif path == "player_on_ice_events"
			highlighted = column == on_ice_sort_column ? "active-link" : ""
			direction = column == on_ice_sort_column && on_ice_sort_direction == "desc" ? "asc" : "desc"
			
			return link_to "#{title}".html_safe, player_path(@player.id,
				on_ice_column: column,
				on_ice_direction: direction,
				penalty_column: params[:penalty_column],
				penalty_direction: params[:penalty_direction],
				game_column: params[:game_column],
				game_direction: params[:game_direction],
				column: params[:column],
				direction: params[:direction],
				season: params[:season],
				situation: params[:situation],
				report: params[:report],
				goalie_report: params[:goalie_report]),
				{ class: "#{highlighted} sort-link", remote: true }

		elsif path == "team_statlines"
    		highlighted = column == sort_column ? "active-link" : ""

			return link_to "#{title}".html_safe, teams_path(
				column: column,
				direction: direction,
				aggregate: params[:aggregate],
				category: params[:category],
				teams: params[:teams],
				seasons: params[:seasons],
				year_start: params[:year_start],
				year_end: params[:year_end],
				regular: params[:regular],
				playoffs: params[:playoffs]),
			{ class: "#{highlighted} sort-link", remote: true }

		elsif path == "team"
			highlighted = column == profile_sort_column ? "active-link" : ""
			direction = column == profile_sort_column && profile_sort_direction == "desc" ? "asc" : "desc"

			return link_to "#{title}".html_safe, team_path(@team,
																profile_sort_column: column,
																profile_sort_direction: direction,
																game_sort_column: params[:game_sort_column],
																game_sort_direction: params[:game_sort_direction],
																season: params[:season],
																regular: params[:regular],
																playoffs: params[:playoffs],
																category: params[:category]),
																{ class: "#{highlighted} sort-link", remote: true }

		elsif path == "team_penalties"
			highlighted = column == penalty_sort_column ? "active-link" : ""
			direction = column == penalty_sort_column && penalty_sort_direction == "desc" ? "asc" : "desc"

			return link_to "#{title}".html_safe, penalties_team_path(@team,
																	penalty_sort_column: column,
																	penalty_sort_direction: direction,
																	season: params[:season]),
																	{ class: "#{highlighted} sort-link", remote: true }

		elsif path == "team_games"
			highlighted = column == game_sort_column ? "active-link" : ""
			direction = column == game_sort_column && game_sort_direction == "desc" ? "asc" : "desc"

			return link_to "#{title}".html_safe, team_path(@team,
															game_sort_column: column,
															game_sort_direction: direction,
															profile_sort_column: params[:profile_sort_column],
															profile_sort_direction: params[:profile_sort_direction],
																	on_ice_direction: direction,
															season: params[:season],
																	category: params[:category]),
															{ class: "#{highlighted} sort-link", remote: true }
		
		elsif path == "opposition_breakdown"
			highlighted = column == ob_column ? "active-link" : ""
			direction = column == ob_column && ob_direction == "desc" ? "asc" : "desc"

			return link_to "#{title}".html_safe, opposition_breakdown_player_path(@player.id,
				ob_column: column,
				ob_direction: direction,
				team: params[:team]),
			{ class: "#{highlighted} sort-link", remote: true }

		end
	end
end
