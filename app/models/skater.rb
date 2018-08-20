class Skater < ApplicationRecord
	validates :player_id, uniqueness: { scope: [:season_id, :team_id] }
	has_many :player_game_statlines, ->(skater) { where(season_id: skater.season_id) },
																		foreign_key: :player_id,
																		primary_key: :player_id,
																		dependent: :destroy
	belongs_to :player, 	primary_key: :cwhl_id,
												foreign_key: :player_id,
												optional: true
	belongs_to :season, 	primary_key: :cwhl_id,
												foreign_key: :season_id,
												optional: true

	belongs_to :team_statline,	->(skater) { where(season_id: skater.season_id) },
															foreign_key: :team_id,
															primary_key: :team_code
	paginates_per 50

	def self.to_csv
		CSV.generate do |csv|
			column_names.delete("created_at")
			column_names.delete("updated_at")
			column_names.delete("shots")
			column_names.delete("shooting_percent")
			column_names.delete("shots_pg")
			column_names.delete("fights")
			column_names.delete("fights_pg")
			csv << column_names
			all.each do |skater|
				csv << skater.attributes.values_at(*column_names)
			end
		end
	end

	def token_name
		return "#{self.first_name.upcase}.#{self.last_name.upcase}"
	end

	def self.tokens_for_option
		skaters = []
		self.all.select(:first_name, :last_name, :player_id).distinct(:player_id).order(last_name: :asc).each do |s|
			skaters << [s.token_name, s.player_id]
		end

		return skaters
	end

	def player_profile
		Player.find_by(cwhl_id: player_id)
	end

	def team_profile_id
		t = TeamStatline.find_by(team_code: self.team_id, season_id: self.season_id)
		Team.find_by(city: t.city, name: t.name, abbreviation: t.abbreviation, team_code: t.team_code).id
	end

	def self.position_options
		p = ["Any", "F", "D", "W", "LW", "RW", "C"]
	end

	def self.handedness_options
		p = ["Any", "L", "R"]
	end

	def self.situation_options
		s = ["All Situations", "Even Strength", "Powerplay", "Shorthanded", "Penalty Shot", "Shootout", "Empty Net"]
	end

	def self.report_options
		s = ["Scoring", "On Ice Breakdown", "Penalty Breakdown"]
	end

	def number
		PlayerGameStatline.where(player_id: player_id, season_id: season_id, team_id: team_id).last.number
	end

	def is_rookie_star
		if self.is_rookie == true
			return "*"
		else
			return ""
		end
	end

	def display_es_gf_p
		return self.gf_p_es if self.gf_p_es.nan?
		return "#{self.gf_p_es}%"
	end

	def display_pp_gf_p
		return self.gf_p_pp if self.gf_p_pp.nan?
		return "#{self.gf_p_pp}%"
	end

	def display_pk_gf_p
		return self.gf_p_pk if self.gf_p_pk.nan?
		return "#{self.gf_p_pk}%"
	end

	def display_en_gf_p
		return self.gf_p_en if self.gf_p_en.nan?
		return "#{self.gf_p_en}%"
	end

	def display_es_rel
		return self.gf_es_rel if self.gf_es_rel.nan? || self.gf_es_rel.nil?
		es_rel = self.gf_es_rel > 0 ? "+#{self.gf_es_rel}%" : "#{self.gf_es_rel}%"
		return es_rel
	end

	def display_gf_5v5_rel
		return self.gf_5v5_rel if self.gf_5v5_rel.nil?  || self.gf_5v5_rel.nan?
		rel = self.gf_5v5_rel > 0 ? "+#{self.gf_5v5_rel}%" : "#{self.gf_5v5_rel}%"
		return rel
	end

	def display_pp_rel
		return self.gf_pp_rel if self.gf_pp_rel.nan? || self.gf_pp_rel.nil?
		pp_rel = self.gf_pp_rel > 0 ? "+#{self.gf_pp_rel}%" : "#{self.gf_pp_rel}%"
		return pp_rel
	end

	def display_pk_rel
		return self.gf_pk_rel if self.gf_pk_rel.nan? || self.gf_pk_rel.nil?
		pk_rel = self.gf_pk_rel > 0 ? "+#{self.gf_pk_rel}%" : "#{self.gf_pk_rel}%"
		return pk_rel
	end

	def self.name_finder(searched)
		searched ||= ""
		terms = ""
		counter = 1

		if searched != ""
			searched.split(' ').each do |term|
				t = '%' + term.gsub("'", "''").gsub(/\d+/, '') + '%'
				if counter == 1
      		terms += "first_name ILIKE '#{t}' OR last_name ILIKE '#{t}'"
      	else
      		terms += " OR first_name ILIKE '#{t}' OR last_name ILIKE '#{t}'"
      	end
      	counter += 1
      	if counter > 10
      		break
      	end
    	end

      where(terms)
		else
			where("first_name != ?", "")
		end
	end

	def self.skater_select(skaters)
		return all if skaters.count <= 0
		skaters.map(&:to_i)

		where(player_id: skaters)
	end

	def self.teams_select(teams)
		return all if teams.nil?
		
		where(team_id:teams.map {|t| t[1]}, team_abbreviation: teams.map {|t| t[0]})
	end

	def self.rookie_select(rookie)
		if rookie == true
			where("is_rookie = ?", true)
		else
			where("is_rookie = ? OR is_rookie = ? OR is_rookie IS NULL", true, false)
		end
	end

	def shooting_percent_as_percent
		(self.shooting_percent * 100).to_s + "%"
	end

	def self.select_handedness(h)
		h ||= "Any"
		if h == "L" || h == "R"
			where("shoots = ?", h)
		else
			where("shoots = ? OR shoots = ? OR shoots = ?", "L", "R", "")
		end
	end

	def self.age_range_select(low, high, exempt_zero)
		if exempt_zero == true
			where("season_age >= ? AND season_age <= ?", low.to_i, high.to_i)
		else
			where("(season_age >= ? AND season_age <= ?) OR season_age = 0", low.to_i, high.to_i)
		end
	end

	def self.position_select(position)
		position ||= "Any"

		if position == "F"
			where("position = ? OR position = ? OR position = ? OR position = ?", "LW", "RW", "C", "F")
		elsif position == "D"
			where("position = ?", "D")
		elsif position == "W"
			where("position = ? OR position = ?", "LW", "RW")
		elsif position == "RW"
			where("position = ?", "RW")
		elsif position == "LW"
			where("position = ?", "LW")
		elsif position == "C"
			where("position = ?", "C")
		else
			where("position = ? OR position = ? OR position = ? OR position = ? OR position = ? OR position = ?", "LW", "RW", "C", "D", "F", "")
		end
	end

	def team_select(teams)
		teams ||= ''
		where("team_id = ?", teams)
	end

	def self.season_select(year_start, year_end, is_regular, is_playoffs)
		if is_regular == false || is_playoffs == false
			season_ids = Season.where('year_start >= ? AND year_end <= ? AND is_regular_season = ? AND is_playoffs = ?', year_start, year_end, is_regular, is_playoffs).pluck(:cwhl_id)
		else
			season_ids = Season.where('year_start >= ? AND year_end <= ? AND year_end != ?', year_start, year_end, year_start).pluck(:cwhl_id)
		end
		return where(season_id: season_ids)
	end

	def self.set_season_ages
		seasons = self.where(season_age: nil).or(self.where(season_age: 0))

		seasons.each do |season|
			profile = Player.find(season.player_id)
			next if profile.birthdate == nil
			season_profile = Season.find_by(cwhl_id: season.season_id)
			season_age = get_age_at_date(season_profile.start_date, profile.birthdate)
			season.update_attributes(season_age: season_age)
		end
	end

	def self.aggregate_and_minimum_games(aggregation_type, minimum_games)
		if aggregation_type == 1
			season_statement = " MAX(season_age) AS season_age,"
			group_statement = 'player_id'
		elsif aggregation_type == 2
			season_statement = " season_age, MIN(season_abbreviation) AS season_abbreviation,"
			group_statement = 'player_id, season_age'
		else
			return all.where('games_played >= ?', minimum_games)
		end

		aggregation_string = "player_id,
							#{season_statement}
							BOOL_OR(is_rookie) AS is_rookie,
							STRING_AGG(DISTINCT(skaters.full_name), '/') AS full_name,
							MAX(last_name) AS last_name,
							MAX(first_name) AS first_name,
							MIN(dob) AS dob,
							MAX(team_id) AS team_id,
							STRING_AGG(DISTINCT(skaters.team_abbreviation), '/') AS team_abbreviation,
							MAX(shoots) AS shoots,
							STRING_AGG(DISTINCT(skaters.position), '/') AS position,
							SUM(games_played) AS games_played,
							SUM(shots) AS shots,
							ROUND(CAST(SUM(goals) AS DECIMAL) / (CASE SUM(shots) WHEN 0 THEN NULL ELSE SUM(shots) END) * 100, 1) AS shooting_percent,
							SUM(goals) AS goals,
							SUM(a1) AS a1,
							SUM(a2) AS a2,
							SUM(points) AS points,
							SUM(pr_points) AS pr_points,
							ROUND(CAST(SUM(shots) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS shots_pg,
							ROUND(CAST(SUM(goals) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS goals_pg,
							ROUND(CAST(SUM(a1) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS a1_pg,
							ROUND(CAST(SUM(a2) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS a2_pg,
							ROUND(CAST(SUM(points) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS points_pg,
							ROUND(CAST(SUM(pr_points) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS pr_points_pg,
							SUM(ev_goals) AS ev_goals,
							SUM(ev_a1) AS ev_a1,
							SUM(ev_a2) AS ev_a2,
							SUM(ev_points) AS ev_points,
							SUM(ev_pr_points) AS ev_pr_points,
							ROUND(CAST(SUM(ev_goals) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS ev_goals_pg,
							ROUND(CAST(SUM(ev_a1) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS ev_a1_pg,
							ROUND(CAST(SUM(ev_a2) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS ev_a2_pg,
							ROUND(CAST(SUM(ev_points) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS ev_points_pg,
							ROUND(CAST(SUM(ev_pr_points) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS ev_pr_points_pg,
							SUM(pp_goals) AS pp_goals,
							SUM(pp_a1) AS pp_a1,
							SUM(pp_a2) AS pp_a2,
							SUM(pp_points) AS pp_points,
							SUM(pp_pr_points) AS pp_pr_points,
							ROUND(CAST(SUM(pp_goals) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS pp_goals_pg,
							ROUND(CAST(SUM(pp_a1) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS pp_a1_pg,
							ROUND(CAST(SUM(pp_a2) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS pp_a2_pg,
							ROUND(CAST(SUM(pp_points) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS pp_points_pg,
							ROUND(CAST(SUM(pp_pr_points) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS pp_pr_points_pg,
							SUM(sh_goals) AS sh_goals,
							SUM(sh_a1) AS sh_a1,
							SUM(sh_a2) AS sh_a2,
							SUM(sh_points) AS sh_points,
							SUM(sh_pr_points) AS sh_pr_points,
							ROUND(CAST(SUM(sh_goals) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS sh_goals_pg,
							ROUND(CAST(SUM(sh_a1) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS sh_a1_pg,
							ROUND(CAST(SUM(sh_a2) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS sh_a2_pg,
							ROUND(CAST(SUM(sh_points) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS sh_points_pg,
							ROUND(CAST(SUM(sh_pr_points) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS sh_pr_points_pg,
							SUM(ps_taken) AS ps_taken,
							SUM(ps_goals) AS ps_goals,
							ROUND(CAST(SUM(ps_goals) AS DECIMAL) / (CASE SUM(ps_taken) WHEN 0 THEN NULL ELSE SUM(ps_taken) END) * 100, 3) AS ps_percent,
							SUM(shootout_attempts) AS shootout_attempts,
							SUM(shootout_goals) AS shootout_goals,
							SUM(shootout_game_winners) AS shootout_game_winners,
							ROUND(CAST(SUM(shootout_goals) AS DECIMAL) / (CASE SUM(shootout_attempts) WHEN 0 THEN NULL ELSE SUM(shootout_attempts) END) * 100, 1) AS shootout_percent,
							SUM(en_goals) AS en_goals,
							SUM(en_a1) AS en_a1,
							SUM(en_a2) AS en_a2,
							SUM(en_points) AS en_points,
							SUM(gf_es) AS gf_es,
							SUM(ga_es) AS ga_es,
							ROUND(CAST(SUM(gf_es) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS gf_es_pg,
							ROUND(CAST(SUM(ga_es) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS ga_es_pg,
							ROUND(CAST(SUM(gf_es) AS DECIMAL) / (CASE (SUM(gf_es) + SUM(ga_es)) WHEN 0 THEN NULL ELSE (SUM(gf_es) + SUM(ga_es)) END) * 100, 2) AS gf_p_es,
							AVG(gf_es_rel) AS gf_es_rel,
							SUM(gf_pp) AS gf_pp,
							SUM(ga_pp) AS ga_pp,
							ROUND(CAST(SUM(gf_pp) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS gf_pp_pg,
							ROUND(CAST(SUM(ga_pp) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS ga_pp_pg,
							ROUND(CAST(SUM(gf_pp) AS DECIMAL) / (CASE (SUM(gf_pp) + SUM(ga_pp)) WHEN 0 THEN NULL ELSE (SUM(gf_pp) + SUM(ga_pp)) END) * 100, 2) AS gf_p_pp,
							AVG(gf_pp_rel) AS gf_pp_rel,
							SUM(gf_pk) AS gf_pk,
							SUM(ga_pk) AS ga_pk,
							ROUND(CAST(SUM(gf_pk) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS gf_pk_pg,
							ROUND(CAST(SUM(ga_pk) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS ga_pk_pg,
							ROUND(CAST(SUM(gf_pk) AS DECIMAL) / (CASE (SUM(gf_pk) + SUM(ga_pk)) WHEN 0 THEN NULL ELSE (SUM(gf_pk) + SUM(ga_pk)) END) * 100, 2) AS gf_p_pk,
							AVG(gf_pk_rel) AS gf_pk_rel,
							AVG(as_ipp) AS as_ipp,
							SUM(gf_5v5) AS gf_5v5,
							SUM(ga_5v5) AS ga_5v5,
							ROUND(CAST(SUM(gf_5v5) AS DECIMAL) / (CASE SUM(gf_5v5) + SUM(ga_5v5) WHEN 0 THEN NULL ELSE SUM(gf_5v5) + SUM(ga_5v5) END) * 100, 2) AS gf_p_5v5,
							AVG(gf_5v5_rel) AS gf_5v5_rel,
							SUM(gf_4v4) AS gf_4v4,
							SUM(ga_4v4) AS ga_4v4,
							ROUND(CAST(SUM(gf_4v4) AS DECIMAL) / (CASE SUM(gf_4v4) + SUM(ga_4v4) WHEN 0 THEN NULL ELSE (SUM(gf_4v4) + SUM(ga_4v4)) END) * 100, 2) AS gf_p_4v4,
							SUM(gf_3v3) AS gf_3v3,
							SUM(ga_3v3) AS ga_3v3,
							ROUND(CAST(SUM(gf_3v3) AS DECIMAL) / (CASE (SUM(gf_3v3) + SUM(ga_3v3)) WHEN 0 THEN NULL ELSE (SUM(gf_3v3) + SUM(ga_3v3)) END) * 100, 2) AS gf_p_3v3,
							AVG(es_ipp) AS es_ipp,
							SUM(gf_5v4) AS gf_5v4,
							SUM(ga_5v4) AS ga_5v4,
							ROUND(CAST(SUM(gf_5v4) AS DECIMAL) / (CASE (SUM(gf_5v4) + SUM(ga_5v4)) WHEN 0 THEN NULL ELSE (SUM(gf_5v4) + SUM(ga_5v4)) END) * 100, 2) AS gf_p_5v4,
							SUM(gf_5v3) AS gf_5v3,
							SUM(ga_5v3) AS ga_5v3,
							ROUND(CAST(SUM(gf_5v3) AS DECIMAL) / (CASE (SUM(gf_5v3) + SUM(ga_5v3)) WHEN 0 THEN NULL ELSE (SUM(gf_5v3) + SUM(ga_5v3)) END) * 100, 2) AS gf_p_5v3,
							SUM(gf_4v3) AS gf_4v3,
							SUM(ga_4v3) AS ga_4v3,
							ROUND(CAST(SUM(gf_4v3) AS DECIMAL) / (CASE (SUM(gf_4v3) + SUM(ga_4v3)) WHEN 0 THEN NULL ELSE (SUM(gf_4v3) + SUM(ga_4v3)) END) * 100, 2) AS gf_p_4v3,
							AVG(pp_ipp) AS pp_ipp,
							SUM(gf_4v5) AS gf_4v5,
							SUM(ga_4v5) AS ga_4v5,
							ROUND(CAST(SUM(gf_4v5) AS DECIMAL) / (CASE (SUM(gf_4v5) + SUM(ga_4v5)) WHEN 0 THEN NULL ELSE (SUM(gf_4v5) + SUM(ga_4v5)) END) * 100, 2) AS gf_p_4v5,
							SUM(gf_3v5) AS gf_3v5,
							SUM(ga_3v5) AS ga_3v5,
							ROUND(CAST(SUM(gf_3v5) AS DECIMAL) / (CASE SUM(gf_3v5) + SUM(ga_3v5) WHEN 0 THEN NULL ELSE SUM(gf_3v5) + SUM(ga_3v5) END) * 100, 2) AS gf_p_3v5,
							SUM(gf_3v4) AS gf_3v4,
							SUM(ga_3v4) AS ga_3v4,
							ROUND(CAST(SUM(gf_3v4) AS DECIMAL) / (CASE (SUM(gf_3v4) + SUM(ga_3v4)) WHEN 0 THEN NULL ELSE (SUM(gf_3v4) + SUM(ga_3v4)) END) * 100, 2) AS gf_p_3v4,
							SUM(gf_enf) AS gf_enf,
							SUM(ga_enf) AS ga_enf,
							ROUND(CAST(SUM(gf_enf) AS DECIMAL) / (CASE (SUM(gf_enf) + SUM(ga_enf)) WHEN 0 THEN NULL ELSE (SUM(gf_enf) + SUM(ga_enf)) END) * 100, 2) AS gf_p_enf,
							SUM(gf_6v5) AS gf_6v5,
							SUM(ga_6v5) AS ga_6v5,
							ROUND(CAST(SUM(gf_6v5) AS DECIMAL) / (CASE (SUM(gf_6v5) + SUM(ga_6v5)) WHEN 0 THEN NULL ELSE (SUM(gf_6v5) + SUM(ga_6v5)) END) * 100, 2) AS gf_p_6v5,
							SUM(gf_6v4) AS gf_6v4,
							SUM(ga_6v4) AS ga_6v4,
							ROUND(CAST(SUM(gf_6v4) AS DECIMAL) / (CASE (SUM(gf_6v4) + SUM(ga_6v4)) WHEN 0 THEN NULL ELSE (SUM(gf_6v4) + SUM(ga_6v4)) END) * 100, 2) AS gf_p_6v4,
							SUM(gf_6v3) AS gf_6v3,
							SUM(ga_6v3) AS ga_6v3,
							ROUND(CAST(SUM(gf_6v3) AS DECIMAL) / (CASE (SUM(gf_6v3) + SUM(ga_6v3)) WHEN 0 THEN NULL ELSE (SUM(gf_6v3) + SUM(ga_6v3)) END) * 100, 2) AS gf_p_6v3,
							SUM(gf_ena) AS gf_ena,
							SUM(ga_ena) AS ga_ena,
							ROUND(CAST(SUM(gf_ena) AS DECIMAL) / (CASE (SUM(gf_ena) + SUM(ga_ena)) WHEN 0 THEN NULL ELSE (SUM(gf_ena) + SUM(ga_ena)) END) * 100, 2) AS gf_p_ena,
							SUM(gf_5v6) AS gf_5v6,
							SUM(ga_5v6) AS ga_5v6,
							ROUND(CAST(SUM(gf_5v6) AS DECIMAL) / (CASE (SUM(gf_5v6) + SUM(ga_5v6)) WHEN 0 THEN NULL ELSE (SUM(gf_5v6) + SUM(ga_5v6)) END) * 100, 2) AS gf_p_5v6,
							SUM(gf_4v6) AS gf_4v6,
							SUM(ga_4v6) AS ga_4v6,
							ROUND(CAST(SUM(gf_4v6) AS DECIMAL) / (CASE (SUM(gf_4v6) + SUM(ga_4v6)) WHEN 0 THEN NULL ELSE (SUM(gf_4v6) + SUM(ga_4v6)) END) * 100, 2) AS gf_p_4v6,
							SUM(gf_3v6) AS gf_3v6,
							SUM(ga_3v6) AS ga_3v6,
							ROUND(CAST(SUM(gf_3v6) AS DECIMAL) / (CASE (SUM(gf_3v6) + SUM(ga_3v6)) WHEN 0 THEN NULL ELSE (SUM(gf_3v6) + SUM(ga_3v6)) END) * 100, 2) AS gf_p_3v6,
							SUM(penalties_taken) AS penalties_taken,
							SUM(penalty_minutes) AS penalty_minutes,
							ROUND(CAST(SUM(penalty_minutes) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS penalty_minutes_pg,
							SUM(minors) AS minors,
							ROUND(CAST(SUM(minors) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS minors_pg,
							SUM(double_minors) AS double_minors,
							ROUND(CAST(SUM(double_minors) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS double_minors_pg,
							SUM(majors) AS majors,
							ROUND(CAST(SUM(majors) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS majors_pg,
							SUM(fights) AS fights,
							ROUND(CAST(SUM(fights) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS fights_pg,
							SUM(misconducts) AS misconducts,
							ROUND(CAST(SUM(misconducts) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS misconducts_pg,
							SUM(game_misconducts) AS game_misconducts,
							ROUND(CAST(SUM(game_misconducts) AS DECIMAL) / CASE SUM(games_played) WHEN 0 THEN NULL ELSE SUM(games_played) END, 3) AS game_misconducts_pg"
							
		group(group_statement).select(aggregation_string).having("SUM(games_played) >= ?", minimum_games)
	end

	def self.update_skater(skater_id, team_id, season_id, scrape_start_time=nil)
		skater = Skater.find_by(player_id: skater_id, team_id: team_id, season_id: season_id)
		player_stats = {  	goals: 0,
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
							sh_points: 0,
							penalties: 0,
							penalty_minutes: 0,
							shooting_percent: 0,
							ps_attempts: 0,
							so_attempts: 0,
							so_goals: 0,
							so_game_winners: 0,
							en_goals: 0,
							en_a1: 0,
							en_a2: 0,
							en_points: 0,
							games_played: 0,
							minors: 0,
							double_minors: 0,
							majors: 0,
							fights: 0,
							misconducts: 0,
							game_misconducts: 0 }

		# Get Games That Player Played In For Selected Season (Store Total)
		games = PlayerGameStatline.where(player_id: skater.player_id, team_id: skater.team_id, season_id: skater.season_id)
		player_stats[:games_played] += games.count

		# Get Penalties That Player Played In For Selected Season (Store Total)
		penalties = Penalty.where(player_id: skater.player_id, team_id: skater.team_id, season_id: skater.season_id)
		player_stats[:penalties] = penalties.count

		# Get Penalty Stats
		penalties.each do |penalty|
			player_stats[:penalty_minutes] += penalty.duration_in_minutes.to_i
		end

		player_stats[:minors] = penalties.where(is_minor: true).count
		player_stats[:double_minors] = penalties.where(is_double_minor: true).count
		player_stats[:majors] = penalties.where(is_major: true).count
		player_stats[:fights] = penalties.where(is_fight: true).count
		player_stats[:misconducts] = penalties.where(is_misconduct: true).count
		player_stats[:game_misconducts] = penalties.where(is_game_misconduct: true).count

		player_stats[:ps_goals] += PenaltyShot.where(player_id: skater.player_id, team_id: skater.team_id, scored: true, season_id: skater.season_id).count
		player_stats[:ps_attempts] += PenaltyShot.where(player_id: skater.player_id, team_id: skater.team_id, season_id: skater.season_id).count

		# Get Empty Net Stats
		team_en_goals = Goal.where(season_id: skater.season_id, team_id: skater.team_id, is_empty_net: true)
		en_goals = team_en_goals.where(goalscorer_id: skater.player_id).count
		en_a1 = team_en_goals.where(a1_id: skater.player_id).count
		en_a2 = team_en_goals.where(a2_id: skater.player_id).count
		en_points = en_goals + en_a1 + en_a2


		# Cycle Through Games And Store Counting Stats
		games.each do |game|
			player_stats[:goals] += game.goals
			player_stats[:a1] += game.a1
			player_stats[:a2] += game.a2
			player_stats[:shots] += game.shots
			player_stats[:ev_goals] += game.ev_goals
			player_stats[:ev_a1] += game.ev_a1
			player_stats[:ev_a2] += game.ev_a2
			player_stats[:pp_goals] += game.pp_goals
			player_stats[:pp_a1] += game.pp_a1
			player_stats[:pp_a2] += game.pp_a2
			player_stats[:sh_goals] += game.sh_goals
			player_stats[:sh_a1] += game.sh_a1
			player_stats[:sh_a2] += game.sh_a2
			player_stats[:points] += game.points
			player_stats[:ev_points] += game.ev_points
			player_stats[:pp_points] += game.pp_points
			player_stats[:sh_points] += game.sh_points
		end

		# Gather All Shootout Attempts During Selected Season
		so_stats = ShootoutAttempt.where(player_id: skater.player_id, season_id: skater.season_id, team_id: skater.team_id)

		# Cycle Through Shootout Attempts And Store Stats
		so_stats.each do |attempt|
			player_stats[:so_attempts] += 1
			player_stats[:so_goals] += 1 if attempt.scored == true
			player_stats[:so_game_winners] += 1 if attempt.game_winner == true
		end

		# Get On Ice Stats
		on_ice_stats = Skater.get_on_ice_goal_stats(skater, scrape_start_time)

		gf_es_p = (BigDecimal.new(on_ice_stats[:gf][:"es"]) / BigDecimal.new(on_ice_stats[:gf][:"es"] + on_ice_stats[:ga][:"es"]))
		gf_pp_p = (BigDecimal.new(on_ice_stats[:gf][:"pp"]) / BigDecimal.new(on_ice_stats[:gf][:"pp"] + on_ice_stats[:ga][:"pp"]))
		gf_pk_p = (BigDecimal.new(on_ice_stats[:gf][:"pk"]) / BigDecimal.new(on_ice_stats[:gf][:"pk"] + on_ice_stats[:ga][:"pk"]))
		gf_5v5_p = (BigDecimal.new(on_ice_stats[:gf][:"5v5"]) / BigDecimal.new(on_ice_stats[:gf][:"5v5"] + on_ice_stats[:ga][:"5v5"]))

		rel_es = gf_es_p - on_ice_stats[:team_wo][:es]
		rel_pp = gf_pp_p - on_ice_stats[:team_wo][:pp]
		rel_pk = gf_pk_p - on_ice_stats[:team_wo][:pk]
		rel_5v5 = gf_5v5_p - on_ice_stats[:team_wo][:"5v5"]

		as_received_point = OnIceSkater.where(player_id: skater.player_id, season_id: skater.season_id, on_scoring_team: true, received_point: true).count
		as_gf_on = OnIceSkater.where(player_id: skater.player_id, season_id: skater.season_id, on_scoring_team: true).count

		es_received_point = OnIceSkater.where(player_id: skater.player_id, season_id: skater.season_id, on_scoring_team: true, received_point: true, is_powerplay: false, is_empty_net: false, is_shorthanded: false).count
		es_gf_on = OnIceSkater.where(player_id: skater.player_id, season_id: skater.season_id, on_scoring_team: true, is_powerplay: false, is_empty_net: false, is_shorthanded: false).count

		pp_received_point = OnIceSkater.where(player_id: skater.player_id, season_id: skater.season_id, on_scoring_team: true, received_point: true, is_powerplay: true).count
		pp_gf_on = OnIceSkater.where(player_id: skater.player_id, season_id: skater.season_id, on_scoring_team: true, is_powerplay: true).count

		as_ipp = as_gf_on != 0 ? (BigDecimal.new(as_received_point) / BigDecimal.new(as_gf_on)) * 100 : 0
		es_ipp = es_gf_on != 0 ? (BigDecimal.new(es_received_point) / BigDecimal.new(es_gf_on)) * 100 : 0
		pp_ipp = pp_gf_on != 0 ? (BigDecimal.new(pp_received_point) / BigDecimal.new(pp_gf_on)) * 100 : 0

		# Update Player Stats With Accumulated Totals
		skater.update_attributes( games_played: player_stats[:games_played],
															goals: player_stats[:goals],
															a1: player_stats[:a1],
															a2: player_stats[:a2],
															shots: player_stats[:shots],
															ev_goals: player_stats[:ev_goals],
															ev_a1: player_stats[:ev_a1],
															ev_a2: player_stats[:ev_a2],
															pp_goals: player_stats[:pp_goals],
															pp_a1: player_stats[:pp_a1],
															pp_a2: player_stats[:pp_a2],
															sh_goals: player_stats[:sh_goals],
															sh_a1: player_stats[:sh_a1],
															sh_a2: player_stats[:sh_a2],
															ps_goals: player_stats[:ps_goals],
															ps_taken: player_stats[:ps_attempts],
															ps_percent: BigDecimal.new(player_stats[:ps_goals]) / BigDecimal.new(player_stats[:ps_attempts]),
															points: player_stats[:points],
															ev_points: player_stats[:ev_points],
															pp_points: player_stats[:pp_points],
															sh_points: player_stats[:sh_points],
															pr_points: player_stats[:goals] + player_stats[:a1],
															ev_pr_points: player_stats[:ev_goals] + player_stats[:ev_a1],
															pp_pr_points: player_stats[:pp_goals] + player_stats[:pp_a1],
															sh_pr_points: player_stats[:sh_goals] + player_stats[:sh_a1],
															en_goals: en_goals,
															en_a1: en_a1,
															en_a2: en_a2,
															en_points: en_points,
															penalties_taken: player_stats[:penalties],
															penalty_minutes: player_stats[:penalty_minutes],
															minors: player_stats[:minors],
															double_minors: player_stats[:double_minors],
															majors: player_stats[:majors],
															fights: player_stats[:fights],
															misconducts: player_stats[:misconducts],
															game_misconducts: player_stats[:game_misconducts],
															# Add in if CWHL starts counting shots: shooting_percent: (BigDecimal.new(player_stats[:goals]) / BigDecimal.new(player_stats[:shots])) * 100,
															# RATE STATS
															goals_pg: (BigDecimal.new(player_stats[:goals]) / BigDecimal.new(player_stats[:games_played])),
															a1_pg: (BigDecimal.new(player_stats[:a1]) / BigDecimal.new(player_stats[:games_played])),
															a2_pg: (BigDecimal.new(player_stats[:a2]) / BigDecimal.new(player_stats[:games_played])),
															shots_pg: (BigDecimal.new(player_stats[:shots]) / BigDecimal.new(player_stats[:games_played])),
															ev_goals_pg: (BigDecimal.new(player_stats[:ev_goals]) / BigDecimal.new(player_stats[:games_played])),
															ev_a1_pg: (BigDecimal.new(player_stats[:ev_a1]) / BigDecimal.new(player_stats[:games_played])),
															ev_a2_pg: (BigDecimal.new(player_stats[:ev_a2]) / BigDecimal.new(player_stats[:games_played])),
															pp_goals_pg: (BigDecimal.new(player_stats[:pp_goals]) / BigDecimal.new(player_stats[:games_played])),
															pp_a1_pg: (BigDecimal.new(player_stats[:pp_a1]) / BigDecimal.new(player_stats[:games_played])),
															pp_a2_pg: (BigDecimal.new(player_stats[:pp_a2]) / BigDecimal.new(player_stats[:games_played])),
															sh_goals_pg: (BigDecimal.new(player_stats[:sh_goals]) / BigDecimal.new(player_stats[:games_played])),
															sh_a1_pg: (BigDecimal.new(player_stats[:sh_a1]) / BigDecimal.new(player_stats[:games_played])),
															sh_a2_pg: (BigDecimal.new(player_stats[:sh_a2]) / BigDecimal.new(player_stats[:games_played])),
															points_pg: (BigDecimal.new(player_stats[:points]) / BigDecimal.new(player_stats[:games_played])),
															ev_points_pg: (BigDecimal.new(player_stats[:ev_points]) / BigDecimal.new(player_stats[:games_played])),
															pp_points_pg: (BigDecimal.new(player_stats[:pp_points]) / BigDecimal.new(player_stats[:games_played])),
															sh_points_pg: (BigDecimal.new(player_stats[:sh_points]) / BigDecimal.new(player_stats[:games_played])),
															pr_points_pg: ((BigDecimal.new(player_stats[:goals]) + BigDecimal.new(player_stats[:a1])) / BigDecimal.new(player_stats[:games_played])),
															ev_pr_points_pg: ((BigDecimal.new(player_stats[:ev_goals]) + BigDecimal.new(player_stats[:ev_a1])) / BigDecimal.new(player_stats[:games_played])),
															pp_pr_points_pg: ((BigDecimal.new(player_stats[:pp_goals]) + BigDecimal.new(player_stats[:pp_a1])) / BigDecimal.new(player_stats[:games_played])),
															sh_pr_points_pg: ((BigDecimal.new(player_stats[:sh_goals]) + BigDecimal.new(player_stats[:sh_a1])) / BigDecimal.new(player_stats[:games_played])),
															penalty_minutes_pg: (BigDecimal.new(player_stats[:penalty_minutes]) / BigDecimal.new(player_stats[:games_played])),
															minors_pg: (BigDecimal.new(player_stats[:minors]) / BigDecimal.new(player_stats[:games_played])),
															double_minors_pg: (BigDecimal.new(player_stats[:double_minors]) / BigDecimal.new(player_stats[:games_played])),
															majors_pg: (BigDecimal.new(player_stats[:majors]) / BigDecimal.new(player_stats[:games_played])),
															fights_pg: (BigDecimal.new(player_stats[:fights]) / BigDecimal.new(player_stats[:games_played])),
															misconducts_pg: (BigDecimal.new(player_stats[:misconducts]) / BigDecimal.new(player_stats[:games_played])),
															game_misconducts_pg: (BigDecimal.new(player_stats[:game_misconducts]) / BigDecimal.new(player_stats[:games_played])),
															shootout_attempts: player_stats[:so_attempts],
															shootout_goals: player_stats[:so_goals],
															shootout_game_winners: player_stats[:so_game_winners],
															shootout_percent: BigDecimal.new(player_stats[:so_goals]) / BigDecimal.new(player_stats[:so_attempts]),
															# ON ICE STATS
															gf_6v5: on_ice_stats[:gf][:"6v5"],
															ga_6v5: on_ice_stats[:ga][:"6v5"],
															gf_p_6v5: 100*(BigDecimal.new(on_ice_stats[:gf][:"6v5"]) / BigDecimal.new(on_ice_stats[:gf][:"6v5"] + on_ice_stats[:ga][:"6v5"])),
															gf_5v6: on_ice_stats[:gf][:"5v6"],
															ga_5v6: on_ice_stats[:ga][:"5v6"],
															gf_p_5v6: 100*(BigDecimal.new(on_ice_stats[:gf][:"5v6"]) / BigDecimal.new(on_ice_stats[:gf][:"5v6"] + on_ice_stats[:ga][:"5v6"])),
															gf_5v5: on_ice_stats[:gf][:"5v5"],
															ga_5v5: on_ice_stats[:ga][:"5v5"],
															gf_p_5v5: 100*(BigDecimal.new(on_ice_stats[:gf][:"5v5"]) / BigDecimal.new(on_ice_stats[:gf][:"5v5"] + on_ice_stats[:ga][:"5v5"])),
															gf_5v4: on_ice_stats[:gf][:"5v4"],
															ga_5v4: on_ice_stats[:ga][:"5v4"],
															gf_p_5v4: 100*(BigDecimal.new(on_ice_stats[:gf][:"5v4"]) / BigDecimal.new(on_ice_stats[:gf][:"5v4"] + on_ice_stats[:ga][:"5v4"])),
															gf_4v5: on_ice_stats[:gf][:"4v5"],
															ga_4v5: on_ice_stats[:ga][:"4v5"],
															gf_p_4v5: 100*(BigDecimal.new(on_ice_stats[:gf][:"4v5"]) / BigDecimal.new(on_ice_stats[:gf][:"4v5"] + on_ice_stats[:ga][:"4v5"])),
															gf_4v4: on_ice_stats[:gf][:"4v4"],
															ga_4v4: on_ice_stats[:ga][:"4v4"],
															gf_p_4v4: 100*(BigDecimal.new(on_ice_stats[:gf][:"4v4"]) / BigDecimal.new(on_ice_stats[:gf][:"4v4"] + on_ice_stats[:ga][:"4v4"])),
															gf_4v3: on_ice_stats[:gf][:"4v3"],
															ga_4v3: on_ice_stats[:ga][:"4v3"],
															gf_p_4v3: 100*(BigDecimal.new(on_ice_stats[:gf][:"4v3"]) / BigDecimal.new(on_ice_stats[:gf][:"4v3"] + on_ice_stats[:ga][:"4v3"])),
															gf_3v4: on_ice_stats[:gf][:"3v4"],
															ga_3v4: on_ice_stats[:ga][:"3v4"],
															gf_p_3v4: 100*(BigDecimal.new(on_ice_stats[:gf][:"3v4"]) / BigDecimal.new(on_ice_stats[:gf][:"3v4"] + on_ice_stats[:ga][:"3v4"])),
															gf_3v3: on_ice_stats[:gf][:"3v3"],
															ga_3v3: on_ice_stats[:ga][:"3v3"],
															gf_p_3v3: 100*(BigDecimal.new(on_ice_stats[:gf][:"3v3"]) / BigDecimal.new(on_ice_stats[:gf][:"3v3"] + on_ice_stats[:ga][:"3v3"])),
															gf_5v3: on_ice_stats[:gf][:"5v3"],
															ga_5v3: on_ice_stats[:ga][:"5v3"],
															gf_p_5v3: 100*(BigDecimal.new(on_ice_stats[:gf][:"5v3"]) / BigDecimal.new(on_ice_stats[:gf][:"5v3"] + on_ice_stats[:ga][:"5v3"])),
															gf_3v5: on_ice_stats[:gf][:"3v5"],
															ga_3v5: on_ice_stats[:ga][:"3v5"],
															gf_p_3v5: 100*(BigDecimal.new(on_ice_stats[:gf][:"3v5"]) / BigDecimal.new(on_ice_stats[:gf][:"3v5"] + on_ice_stats[:ga][:"3v5"])),
															gf_6v3: on_ice_stats[:gf][:"6v3"],
															ga_6v3: on_ice_stats[:ga][:"6v3"],
															gf_p_6v3: 100*(BigDecimal.new(on_ice_stats[:gf][:"6v3"]) / BigDecimal.new(on_ice_stats[:gf][:"6v3"] + on_ice_stats[:ga][:"6v3"])),
															gf_3v6: on_ice_stats[:gf][:"3v6"],
															ga_3v6: on_ice_stats[:ga][:"3v6"],
															gf_p_3v6: 100*(BigDecimal.new(on_ice_stats[:gf][:"3v6"]) / BigDecimal.new(on_ice_stats[:gf][:"3v6"] + on_ice_stats[:ga][:"3v6"])),
															gf_6v4: on_ice_stats[:gf][:"6v4"],
															ga_6v4: on_ice_stats[:ga][:"6v4"],
															gf_p_6v4: 100*(BigDecimal.new(on_ice_stats[:gf][:"6v4"]) / BigDecimal.new(on_ice_stats[:gf][:"6v4"] + on_ice_stats[:ga][:"6v4"])),
															gf_4v6: on_ice_stats[:gf][:"4v6"],
															ga_4v6: on_ice_stats[:ga][:"4v6"],
															gf_p_4v6: 100*(BigDecimal.new(on_ice_stats[:gf][:"4v6"]) / BigDecimal.new(on_ice_stats[:gf][:"4v6"] + on_ice_stats[:ga][:"4v6"])),
															gf_es: on_ice_stats[:gf][:"es"],
															ga_es: on_ice_stats[:ga][:"es"],
															gf_p_es: 100*(BigDecimal.new(on_ice_stats[:gf][:"es"]) / BigDecimal.new(on_ice_stats[:gf][:"es"] + on_ice_stats[:ga][:"es"])),
															gf_pp: on_ice_stats[:gf][:"pp"],
															ga_pp: on_ice_stats[:ga][:"pp"],
															gf_p_pp: 100*(BigDecimal.new(on_ice_stats[:gf][:"pp"]) / BigDecimal.new(on_ice_stats[:gf][:"pp"] + on_ice_stats[:ga][:"pp"])),
															gf_pk: on_ice_stats[:gf][:"pk"],
															ga_pk: on_ice_stats[:ga][:"pk"],
															gf_p_pk: 100*(BigDecimal.new(on_ice_stats[:gf][:"pk"]) / BigDecimal.new(on_ice_stats[:gf][:"pk"] + on_ice_stats[:ga][:"pk"])),
															gf_enf: on_ice_stats[:gf][:"enf"],
															ga_enf: on_ice_stats[:ga][:"enf"],
															gf_p_enf: BigDecimal.new(on_ice_stats[:gf][:"enf"]) / BigDecimal.new(on_ice_stats[:gf][:"enf"] + on_ice_stats[:ga][:"enf"]),
															gf_ena: on_ice_stats[:gf][:"ena"],
															ga_ena: on_ice_stats[:ga][:"ena"],
															gf_p_ena: BigDecimal.new(on_ice_stats[:gf][:"ena"]) / BigDecimal.new(on_ice_stats[:gf][:"ena"] + on_ice_stats[:ga][:"ena"]),
															gf_es_pg: BigDecimal.new(on_ice_stats[:gf][:"es"]) / BigDecimal.new(player_stats[:games_played]),
															ga_es_pg: BigDecimal.new(on_ice_stats[:ga][:"es"]) / BigDecimal.new(player_stats[:games_played]),
															gf_pp_pg: BigDecimal.new(on_ice_stats[:gf][:"pp"]) / BigDecimal.new(player_stats[:games_played]),
															ga_pp_pg: BigDecimal.new(on_ice_stats[:ga][:"pp"]) / BigDecimal.new(player_stats[:games_played]),
															gf_pk_pg: BigDecimal.new(on_ice_stats[:gf][:"pk"]) / BigDecimal.new(player_stats[:games_played]),
															ga_pk_pg: BigDecimal.new(on_ice_stats[:ga][:"pk"]) / BigDecimal.new(player_stats[:games_played]),
															gf_es_rel: 100*rel_es,
															gf_pp_rel: 100*rel_pp,
															gf_pk_rel: 100*rel_pk,
															gf_5v5_rel: 100*rel_5v5,
															# iPP
															as_ipp: as_ipp,
															es_ipp: es_ipp,
															pp_ipp: pp_ipp
														)
	end

	def self.update_skaters(created_games, scrape_start_time)
		skaters = []

		# Get Team ID's With Season ID's To Isolate What To Update
		created_games.each do |game|
			game.skaters.each do |skater|
				skaters << [skater.player_id, skater.team_id, game.season_id]
			end
		end

		# Remove Duplicates
		skaters.uniq!

		skaters.each do |skater_id, team_id, season_id|
			Skater.update_skater(skater_id, team_id, season_id, scrape_start_time)
		end
	end

	def self.update_all_skaters
		skaters = Skater.all
		time = Time.now

		skaters.each do |skater|
			Skater.update_skater(skater.player_id, skater.team_id, skater.season_id, time)
		end
	end

	def self.update_positions()
		require 'open-uri'
		skaters = Skater.where(position: "F")

		skaters.each do |skater|

			pgs = PlayerGameStatline.where(player_id: skater.player_id)
			pgs.each do |game|
				if game.position != "F"
					skater.position = game.position
					skater.save

					break
				end
			end
		end

	end

	def self.get_age_at_date(date, birthdate)
		BigDecimal.new((date - birthdate).to_i) / BigDecimal.new(365)
	end

	def self.get_on_ice_goal_stats(skater, scrape_start_time)
		skater_stats = {
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
				"as": 0,
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
				"as": 0,
				"es": 0,
				"pp": 0,
				"pk": 0,
				"enf": 0,
				"ena": 0
			}
		}
		on_ice_goals_for = OnIceSkater.where(season_id: skater.season_id, player_id: skater.player_id, team_id: skater.team_id, on_scoring_team: true)
		on_ice_goals_against = OnIceSkater.where(season_id: skater.season_id, player_id: skater.player_id, team_id: skater.team_id, on_scoring_team: false)

		on_ice_goals_for.each do |goal|
			teammate_number = goal.teammate_count
			opponent_number = goal.opposing_skaters_count
			next if teammate_number < 3 || teammate_number > 6 || opponent_number < 3 || opponent_number > 6 || (opponent_number == 6 && teammate_number == 6)

			situation_symbol = "#{teammate_number}v#{opponent_number}".to_sym

			skater_stats[:gf][situation_symbol] += 1
			skater_stats[:gf][:"as"] += 1
		end

		on_ice_goals_against.each do |goal|
			teammate_number = goal.teammate_count
			opponent_number = goal.opposing_skaters_count
			next if teammate_number < 3 || teammate_number > 6 || opponent_number < 3 || opponent_number > 6 || (opponent_number == 6 && teammate_number == 6)

			situation_symbol = "#{teammate_number}v#{opponent_number}".to_sym

			skater_stats[:ga][situation_symbol] += 1
			skater_stats[:ga][:"as"] += 1
		end

		# Get Totals For ES, PP, PK
		skater_stats[:gf][:"es"] = skater_stats[:gf][:"5v5"] + skater_stats[:gf][:"4v4"] + skater_stats[:gf][:"3v3"]
		skater_stats[:gf][:"pp"] = skater_stats[:gf][:"5v4"] + skater_stats[:gf][:"5v3"] + skater_stats[:gf][:"4v3"]
		skater_stats[:gf][:"pk"] = skater_stats[:gf][:"4v5"] + skater_stats[:gf][:"3v5"] + skater_stats[:gf][:"3v4"]
		skater_stats[:gf][:"enf"] = skater_stats[:gf][:"6v5"] + skater_stats[:gf][:"6v4"] + skater_stats[:gf][:"6v3"]
		skater_stats[:gf][:"ena"] = skater_stats[:gf][:"5v6"] + skater_stats[:gf][:"4v6"] + skater_stats[:gf][:"3v6"]

		skater_stats[:ga][:"es"] = skater_stats[:ga][:"5v5"] + skater_stats[:ga][:"4v4"] + skater_stats[:ga][:"3v3"]
		skater_stats[:ga][:"pp"] = skater_stats[:ga][:"5v4"] + skater_stats[:ga][:"5v3"] + skater_stats[:ga][:"4v3"]
		skater_stats[:ga][:"pk"] = skater_stats[:ga][:"4v5"] + skater_stats[:ga][:"3v5"] + skater_stats[:ga][:"3v4"]
		skater_stats[:ga][:"enf"] = skater_stats[:ga][:"6v5"] + skater_stats[:ga][:"6v4"] + skater_stats[:ga][:"6v3"]
		skater_stats[:ga][:"ena"] = skater_stats[:ga][:"5v6"] + skater_stats[:ga][:"4v6"] + skater_stats[:ga][:"3v6"]

		# Get Relative Stats
		team = TeamStatline.find_by(season_id: skater.season_id, team_code: skater.team_id)
		TeamStatline.update_on_ice_results(team) unless scrape_start_time == nil || team.updated_at > scrape_start_time

		team_es_gf_wo = team.es_on_ice_gf - skater_stats[:gf][:"es"]
		team_es_ga_wo = team.es_on_ice_ga - skater_stats[:ga][:"es"]
		team_pp_gf_wo = team.pp_on_ice_gf - skater_stats[:gf][:"pp"]
		team_pp_ga_wo = team.pp_on_ice_ga - skater_stats[:ga][:"pp"]
		team_pk_gf_wo = team.pk_on_ice_gf - skater_stats[:gf][:"pk"]
		team_pk_ga_wo = team.pk_on_ice_ga - skater_stats[:ga][:"pk"]
		team_5v5_gf_wo = team.gf_5v5 - skater_stats[:gf][:"5v5"]
		team_5v5_ga_wo = team.ga_5v5 - skater_stats[:ga][:"5v5"]

		skater_stats[:team_wo] = {}
		skater_stats[:team_wo][:es] = BigDecimal(team_es_gf_wo) / BigDecimal(team_es_gf_wo + team_es_ga_wo)
		skater_stats[:team_wo][:pp] = BigDecimal(team_pp_gf_wo) / BigDecimal(team_pp_gf_wo + team_pp_ga_wo)
		skater_stats[:team_wo][:pk] = BigDecimal(team_pk_gf_wo) / BigDecimal(team_pk_gf_wo + team_pk_ga_wo)
		skater_stats[:team_wo][:"5v5"] = BigDecimal(team_5v5_gf_wo) / BigDecimal(team_5v5_gf_wo + team_5v5_ga_wo)

		return skater_stats
	end

	private
		def self.get_age_at_date(date, birthdate)
			BigDecimal.new((date - birthdate).to_i) / BigDecimal.new(365)
		end
end
