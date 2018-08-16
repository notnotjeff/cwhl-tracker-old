class TeamStatline < ApplicationRecord
	validates_uniqueness_of :team_id, scope: [:season_id, :team_code]
	paginates_per 50

	belongs_to :teams, 	primary_key: :id,
											foreign_key: :team_id,
											optional: true
	has_many :team_game_statlines, ->(team) { where(season_id: team.season_id) },
																		foreign_key: :team_id,
																		primary_key: :team_code,
																		dependent: :destroy
	has_many :skaters, ->(team) { where(season_id: team.season_id) },
																		foreign_key: :team_id,
																		primary_key: :team_code
	has_many :goalies, ->(team) { where(season_id: team.season_id) },
																		foreign_key: :team_id,
																		primary_key: :team_code

	def self.to_csv
		CSV.generate do |csv|
			column_names.delete("created_at")
			column_names.delete("updated_at")
			column_names.delete("division_id")
			csv << column_names
			all.each do |team|
				csv << team.attributes.values_at(*column_names)
			end
		end
	end

	def self.stat_categories
		["Game Stats", "Shot Stats", "Goal Stats", "Shootout Stats", "Period Breakdown", "Even Strength Goal Breakdown", "Powerplay Goal Breakdown", "Shorthanded Goal Breakdown", "Empty Net Goal Breakdown", "Penalty Breakdown"]
	end

	def season
		Season.find_by(cwhl_id: self.season_id).abbreviation
	end

	def shots_percent_as_percent
		return "0%" if self.shots_percent == nil
		(self.shots_percent * 100).to_s + "%"
	end

	def shootout_percent_as_percent
		return "0%" if self.shots_percent == nil
		(self.shootout_percent * 100).to_s + "%"
	end

	def team_logo_url
		return "unknown.png" if Team.find_by(city: self.city, name: self.name, abbreviation: self.abbreviation, team_code: self.team_code).nil?
		Team.find_by(city: self.city, name: self.name, abbreviation: self.abbreviation, team_code: self.team_code).logo_url
	end

	def self.teams_select(teams)
		return all if teams.nil?

		where(team_code: teams.map {|t| t[1]}, abbreviation: teams.map {|t| t[0]})
	end

	def self.aggregate(should_aggregate)
		return all if should_aggregate == false
		
		group('team_code').select("team_code, 
										STRING_AGG(DISTINCT(team_statlines.full_name), '/') AS full_name,
										STRING_AGG(DISTINCT(team_statlines.city), '/') AS city,
										STRING_AGG(DISTINCT(team_statlines.name), '/') AS name,
										STRING_AGG(DISTINCT(team_statlines.abbreviation), '/') AS abbreviation,
										MAX(team_id) AS team_id,
										ROUND(CAST(SUM(points) AS DECIMAL) / (SUM(games_played) * 2), 3) AS points_percentage,
										SUM(games_played) AS games_played, 
										SUM(wins) AS wins,
										SUM(ot_wins) AS ot_wins,
										SUM(so_wins) AS so_wins,
										SUM(losses) AS losses,
										SUM(ot_losses) AS ot_losses,
										SUM(so_losses) AS so_losses,
										SUM(points) AS points,
										SUM(row) AS row,
										SUM(goals_for) AS goals_for,
										SUM(goals_against) AS goals_against,
										SUM(penalty_minutes) AS penalty_minutes,
										ROUND(CAST(SUM(goals_for) AS DECIMAL) / CASE SUM(shots) WHEN 0 THEN NULL ELSE SUM(shots) END * 100, 2) AS shooting_percent,
										ROUND((CAST(SUM(shots_against) AS DECIMAL) - SUM(goals_against)) / CASE SUM(shots_against) WHEN 0 THEN NULL ELSE SUM(shots_against) END * 100, 2) AS save_percent,
										ROUND((CAST(SUM(goals_for) AS DECIMAL) / SUM(shots) * 100) + ((CAST(SUM(shots_against) AS DECIMAL) - SUM(goals_against)) / SUM(shots_against) * 100), 2) AS pdo,
										SUM(shots) AS shots,
										SUM(shots_against) AS shots_against,
										ROUND(CAST(SUM(shots) AS DECIMAL) / SUM(games_played), 3) AS shots_pg,
										ROUND(CAST(SUM(shots_against) AS DECIMAL) / SUM(games_played), 3) AS shots_against_pg,
										ROUND(CAST(SUM(shots) AS DECIMAL) / (SUM(shots) + SUM(shots_against)), 3) AS shots_percent,
										SUM(first_period_shots) AS first_period_shots,
										SUM(second_period_shots) AS second_period_shots,
										SUM(third_period_shots) AS third_period_shots,
										SUM(ot_shots) AS ot_shots,
										ROUND(CAST(SUM(first_period_shots) AS DECIMAL) / SUM(games_played), 3) AS first_period_shots_pg,
										ROUND(CAST(SUM(second_period_shots) AS DECIMAL) / SUM(games_played), 3) AS second_period_shots_pg,
										ROUND(CAST(SUM(third_period_shots) AS DECIMAL) / SUM(games_played), 3) AS third_period_shots_pg,
										ROUND(CAST(SUM(ot_shots) AS DECIMAL) / CASE SUM(ot_periods) WHEN 0 THEN NULL ELSE SUM(ot_periods) END, 3) AS ot_period_shots_pg,
										SUM(ev_goals_for) AS ev_goals_for,
										SUM(ev_goals_against) AS ev_goals_against,
										SUM(pp_goals_for) AS pp_goals_for,
										SUM(pp_goals_against) AS pp_goals_against,
										SUM(sh_goals_for) AS sh_goals_for,
										SUM(sh_goals_against) AS sh_goals_against,
										ROUND(CAST(SUM(goals_for) AS DECIMAL) / SUM(games_played), 3) AS goals_for_pg,
										ROUND(CAST(SUM(goals_against) AS DECIMAL) / SUM(games_played), 3) AS goals_against_pg,
										ROUND(CAST(SUM(goals_for) AS DECIMAL) / (CASE SUM(goals_for) + SUM(goals_against) WHEN 0 THEN NULL ELSE SUM(goals_for) + SUM(goals_against) END) * 100, 3) AS goals_percent,
										ROUND(CAST(SUM(ev_goals_for) AS DECIMAL) / SUM(games_played), 3) AS ev_goals_for_pg,
										ROUND(CAST(SUM(ev_goals_against) AS DECIMAL) / SUM(games_played), 3) AS ev_goals_against_pg,
										ROUND(CAST(SUM(ev_goals_for) AS DECIMAL) / (CASE SUM(ev_goals_for) + SUM(ev_goals_against) WHEN 0 THEN NULL ELSE SUM(ev_goals_for) + SUM(ev_goals_against) END) * 100, 3) AS ev_goals_percent,
										ROUND(CAST(SUM(pp_goals_for) AS DECIMAL) / SUM(games_played), 3) AS pp_goals_for_pg,
										ROUND(CAST(SUM(pp_goals_against) AS DECIMAL) / SUM(games_played), 3) AS pp_goals_against_pg,
										ROUND(CAST(SUM(sh_goals_for) AS DECIMAL) / SUM(games_played), 3) AS sh_goals_for_pg,
										ROUND(CAST(SUM(sh_goals_against) AS DECIMAL) / SUM(games_played), 3) AS sh_goals_against_pg,
										SUM(shootout_attempts) AS shootout_attempts,
										SUM(shootout_goals) AS shootout_goals,
										ROUND(CAST(SUM(shootout_goals) AS DECIMAL) / (CASE SUM(shootout_attempts) WHEN 0 THEN NULL ELSE SUM(shootout_attempts) END) * 100, 2) AS shootout_percent,
										SUM(first_period_goals) AS first_period_goals,
										SUM(second_period_goals) AS second_period_goals,
										SUM(third_period_goals) AS third_period_goals,
										SUM(ot_shots) AS ot_shots,
										SUM(ot_period_goals) AS ot_period_goals,
										ROUND(CAST(SUM(first_period_goals) AS DECIMAL) / SUM(games_played), 3) AS first_period_goals_pg,
										ROUND(CAST(SUM(second_period_goals) AS DECIMAL) / SUM(games_played), 3) AS second_period_goals_pg,
										ROUND(CAST(SUM(third_period_goals) AS DECIMAL) / SUM(games_played), 3) AS third_period_goals_pg,
										ROUND(CAST(SUM(ot_period_goals) AS DECIMAL) / CASE SUM(ot_periods) WHEN 0 THEN NULL ELSE SUM(ot_periods) END, 3) AS ot_period_goals_pg,
										SUM(gf_5v5) AS gf_5v5,
										SUM(ga_5v5) AS ga_5v5,
										ROUND(CAST(SUM(gf_5v5) AS DECIMAL) / ( CASE SUM(gf_5v5) + SUM(ga_5v5) WHEN 0 THEN NULL ELSE SUM(gf_5v5) + SUM(ga_5v5) END ) * 100, 3) AS gf_p_5v5,
										SUM(gf_4v4) AS gf_4v4,
										SUM(ga_4v4) AS ga_4v4,
										ROUND(CAST(SUM(gf_4v4) AS DECIMAL) / ( CASE SUM(gf_4v4) + SUM(ga_4v4) WHEN 0 THEN NULL ELSE SUM(gf_4v4) + SUM(ga_4v4) END ) * 100, 3) AS gf_p_4v4,
										SUM(gf_3v3) AS gf_3v3,
										SUM(ga_3v3) AS ga_3v3,
										ROUND(CAST(SUM(gf_3v3) AS DECIMAL) / ( CASE SUM(gf_3v3) + SUM(ga_3v3) WHEN 0 THEN NULL ELSE SUM(gf_3v3) + SUM(ga_3v3) END ) * 100, 3) AS gf_p_3v3,
										SUM(gf_5v4) AS gf_5v4,
										SUM(ga_5v4) AS ga_5v4,
										SUM(gf_5v3) AS gf_5v3,
										SUM(ga_5v3) AS ga_5v3,
										SUM(gf_4v3) AS gf_4v3,
										SUM(ga_4v3) AS ga_4v3,
										SUM(gf_4v5) AS gf_4v5,
										SUM(ga_4v5) AS ga_4v5,
										SUM(gf_3v5) AS gf_3v5,
										SUM(ga_3v5) AS ga_3v5,
										SUM(gf_3v4) AS gf_3v4,
										SUM(ga_3v4) AS ga_3v4,
										SUM(gf_6v5) AS gf_6v5,
										SUM(ga_6v5) AS ga_6v5,
										SUM(gf_6v4) AS gf_6v4,
										SUM(ga_6v4) AS ga_6v4,
										SUM(gf_6v3) AS gf_6v3,
										SUM(ga_6v3) AS ga_6v3,
										SUM(gf_5v6) AS gf_5v6,
										SUM(ga_5v6) AS ga_5v6,
										SUM(gf_4v6) AS gf_4v6,
										SUM(ga_4v6) AS ga_4v6,
										SUM(gf_3v6) AS gf_3v6,
										SUM(ga_3v6) AS ga_3v6,
										SUM(minors) AS minors,
										ROUND(CAST(SUM(minors) AS DECIMAL) / SUM(games_played), 3) AS minors_pg,
										SUM(majors) AS majors,
										ROUND(CAST(SUM(majors) AS DECIMAL) / SUM(games_played), 3) AS majors_pg,
										SUM(double_minors) AS double_minors,
										ROUND(CAST(SUM(double_minors) AS DECIMAL) / SUM(games_played), 3) AS double_minors_pg,
										SUM(fights) AS fights,
										ROUND(CAST(SUM(fights) AS DECIMAL) / SUM(games_played), 3) AS fights_pg,
										SUM(misconducts) AS misconducts,
										ROUND(CAST(SUM(misconducts) AS DECIMAL) / SUM(games_played), 3) AS misconducts_pg,
										SUM(game_misconducts) AS game_misconducts,
										ROUND(CAST(SUM(game_misconducts) AS DECIMAL) / SUM(games_played), 3) AS game_misconducts_pg,
										SUM(es_on_ice_gf) AS es_on_ice_gf,
										SUM(es_on_ice_ga) AS es_on_ice_ga,
										SUM(pp_on_ice_gf) AS pp_on_ice_gf,
										SUM(pp_on_ice_ga) AS pp_on_ice_ga,
										SUM(pk_on_ice_gf) AS pk_on_ice_gf,
										SUM(pk_on_ice_ga) AS pk_on_ice_ga,
										SUM(en_on_ice_gf) AS en_on_ice_gf,
										SUM(en_on_ice_ga) AS en_on_ice_ga
										")
	end

	def self.season_select(year_start, year_end, is_regular, is_playoffs)
		if is_regular == false || is_playoffs == false
			season_ids = Season.where('year_start >= ? AND year_end <= ? AND is_regular_season = ? AND is_playoffs = ?', year_start, year_end, is_regular, is_playoffs).pluck(:cwhl_id)
		else
			season_ids = Season.where('year_start >= ? AND year_end <= ?', year_start, year_end).pluck(:cwhl_id)
		end
		return where(season_id: season_ids)
	end

	def self.update_on_ice_results(team)
		goals_for = Goal.where(season_id: team.season_id, team_id: team.team_code)
		goals_against = Goal.where(season_id: team.season_id, opposing_team_id: team.team_code)
		on_ice_results = {
			:gf => {
				"6v5": 0,
				"5v6": 0,
				"6v4": 0,
				"4v6": 0,
				"6v3": 0,
				"3v6": 0,
				"5v5": 0,
				"5v4": 0,
				"4v5": 0,
				"5v3": 0,
				"3v5": 0,
				"4v4": 0,
				"4v3": 0,
				"3v4": 0,
				"3v3": 0,
				"es": 0,
				"pp": 0,
				"pk": 0,
				"enf": 0,
				"ena": 0
			},
			:ga => {
				"6v5": 0,
				"5v6": 0,
				"6v4": 0,
				"4v6": 0,
				"6v3": 0,
				"3v6": 0,
				"5v5": 0,
				"5v4": 0,
				"4v5": 0,
				"5v3": 0,
				"3v5": 0,
				"4v4": 0,
				"4v3": 0,
				"3v4": 0,
				"3v3": 0,
				"es": 0,
				"pp": 0,
				"pk": 0,
				"enf": 0,
				"ena": 0
			}
		}

		goals_for.each do |goal|
			teammate_number = goal.team_player_count
			opponent_number = goal.opposing_team_player_count
			next if teammate_number < 3 || teammate_number > 6 || opponent_number < 3 || opponent_number > 6 || (opponent_number == 6 && teammate_number == 6)

			situation_symbol = "#{teammate_number}v#{opponent_number}".to_sym

			on_ice_results[:gf][situation_symbol] += 1
		end

		goals_against.each do |goal|
			teammate_number = goal.opposing_team_player_count
			opponent_number = goal.team_player_count
			next if teammate_number < 3 || teammate_number > 6 || opponent_number < 3 || opponent_number > 6 || (opponent_number == 6 && teammate_number == 6)

			situation_symbol = "#{teammate_number}v#{opponent_number}".to_sym

			on_ice_results[:ga][situation_symbol] += 1
		end

		# Get Totals For ES, PP, PK
		on_ice_results[:gf][:"es"] = on_ice_results[:gf][:"5v5"] + on_ice_results[:gf][:"4v4"] + on_ice_results[:gf][:"3v3"]
		on_ice_results[:gf][:"pp"] = on_ice_results[:gf][:"5v4"] + on_ice_results[:gf][:"5v3"] + on_ice_results[:gf][:"4v3"]
		on_ice_results[:gf][:"pk"] = on_ice_results[:gf][:"4v5"] + on_ice_results[:gf][:"3v5"] + on_ice_results[:gf][:"3v4"]
		on_ice_results[:gf][:"enf"] = on_ice_results[:gf][:"6v5"] + on_ice_results[:gf][:"6v4"] + on_ice_results[:gf][:"6v3"]
		on_ice_results[:gf][:"ena"] = on_ice_results[:gf][:"5v6"] + on_ice_results[:gf][:"4v6"] + on_ice_results[:gf][:"3v6"]

		on_ice_results[:ga][:"es"] = on_ice_results[:ga][:"5v5"] + on_ice_results[:ga][:"4v4"] + on_ice_results[:ga][:"3v3"]
		on_ice_results[:ga][:"pp"] = on_ice_results[:ga][:"5v4"] + on_ice_results[:ga][:"5v3"] + on_ice_results[:ga][:"4v3"]
		on_ice_results[:ga][:"pk"] = on_ice_results[:ga][:"4v5"] + on_ice_results[:ga][:"3v5"] + on_ice_results[:ga][:"3v4"]
		on_ice_results[:ga][:"enf"] = on_ice_results[:ga][:"6v5"] + on_ice_results[:ga][:"6v4"] + on_ice_results[:ga][:"6v3"]
		on_ice_results[:ga][:"ena"] = on_ice_results[:ga][:"5v6"] + on_ice_results[:ga][:"4v6"] + on_ice_results[:ga][:"3v6"]

		team.update_attributes(	es_on_ice_gf: on_ice_results[:gf][:"es"],
														es_on_ice_ga: on_ice_results[:ga][:"es"],
														pp_on_ice_gf: on_ice_results[:gf][:"pp"],
														pp_on_ice_ga: on_ice_results[:ga][:"pp"],
														pk_on_ice_gf: on_ice_results[:gf][:"pk"],
														pk_on_ice_ga: on_ice_results[:ga][:"pk"],
														gf_6v5: on_ice_results[:gf][:"6v5"],
														ga_6v5: on_ice_results[:ga][:"6v5"],
														gf_5v6: on_ice_results[:gf][:"5v6"],
														ga_5v6: on_ice_results[:ga][:"5v6"],
														gf_5v5: on_ice_results[:gf][:"5v5"],
														ga_5v5: on_ice_results[:ga][:"5v5"],
														gf_p_5v5: 100 * (BigDecimal.new(on_ice_results[:gf][:"5v5"]) / BigDecimal.new(on_ice_results[:gf][:"5v5"] + on_ice_results[:ga][:"5v5"])),
														gf_5v4: on_ice_results[:gf][:"5v4"],
														ga_5v4: on_ice_results[:ga][:"5v4"],
														gf_4v5: on_ice_results[:gf][:"4v5"],
														ga_4v5: on_ice_results[:ga][:"4v5"],
														gf_4v4: on_ice_results[:gf][:"4v4"],
														ga_4v4: on_ice_results[:ga][:"4v4"],
														gf_p_4v4: 100 * (BigDecimal.new(on_ice_results[:gf][:"4v4"]) / BigDecimal.new(on_ice_results[:gf][:"4v4"] + on_ice_results[:ga][:"4v4"])),
														gf_4v3: on_ice_results[:gf][:"4v3"],
														ga_4v3: on_ice_results[:ga][:"4v3"],
														gf_3v4: on_ice_results[:gf][:"3v4"],
														ga_3v4: on_ice_results[:ga][:"3v4"],
														gf_3v3: on_ice_results[:gf][:"3v3"],
														ga_3v3: on_ice_results[:ga][:"3v3"],
														gf_p_3v3: 100 * (BigDecimal.new(on_ice_results[:gf][:"3v3"]) / BigDecimal.new(on_ice_results[:gf][:"3v3"] + on_ice_results[:ga][:"3v3"])),
														gf_5v3: on_ice_results[:gf][:"5v3"],
														ga_5v3: on_ice_results[:ga][:"5v3"],
														gf_3v5: on_ice_results[:gf][:"3v5"],
														ga_3v5: on_ice_results[:ga][:"3v5"],
														gf_6v3: on_ice_results[:gf][:"6v3"],
														ga_6v3: on_ice_results[:ga][:"6v3"],
														gf_3v6: on_ice_results[:gf][:"3v6"],
														ga_3v6: on_ice_results[:ga][:"3v6"],
														gf_6v4: on_ice_results[:gf][:"6v4"],
														ga_6v4: on_ice_results[:ga][:"6v4"],
														gf_4v6: on_ice_results[:gf][:"4v6"],
														ga_4v6: on_ice_results[:ga][:"4v6"]
													)
	end
end
