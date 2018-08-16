class Season < ApplicationRecord
	validates_uniqueness_of :cwhl_id
	has_many :games,  				foreign_key: :season_id,
														primary_key: :cwhl_id,
														dependent: :destroy
	has_many :team_statlines, foreign_key: :season_id,
														primary_key: :cwhl_id,
														dependent: :destroy
	has_many :skaters, 				foreign_key: :season_id,
														primary_key: :cwhl_id,
														dependent: :destroy
	has_many :goalies, 				foreign_key: :season_id,
														primary_key: :cwhl_id,
														class_name: 'Goalie',
														dependent: :destroy

	def self.current_season_start
		self.find_by(current_season: true).year_start.to_i
	end

	def self.current_season_end
		self.find_by(current_season: true).year_end.to_i
	end

	def self.current_season_id
		self.find_by(current_season:true).cwhl_id.to_i
	end

	def self.current_playoffs_id
		self.where(is_playoffs: true).order(year_start: :desc).first.cwhl_id.to_i
	end

	def self.year_start_for_option
		return Season.where.not(year_start: nil).order(year_start: :asc).pluck(:year_start).uniq
	end

	def self.year_end_for_option
		return Season.where.not(year_end: nil).order(year_end: :asc).pluck(:year_end).uniq
	end

	def self.years_for_option
		seasons = [["All", 0], ["Regular Seasons", -1], ["Playoffs", -2]]
		Season.where(is_regular_season: true).or(Season.where(is_playoffs: true)).order(cwhl_id: :desc).each do |s|
			seasons << [s.token, s.cwhl_id]
		end

		return seasons
	end

	def self.playoffs_for_option
		seasons = [["All", 0]]
		Season.where(is_playoffs: true).order(cwhl_id: :desc).each do |s|
			seasons << [s.token, s.cwhl_id]
		end

		return seasons
	end

	def token
		return self.year_start != self.year_end ? "#{self.year_start}-#{self.year_end.to_s.last(2)}" : "#{self.year_start}#{self.abbreviation.to_s.last(2)}"
	end

	def self.seasons_for_option
		seasons = []
		Season.where(is_regular_season: true).or(Season.where(is_playoffs: true)).order(cwhl_id: :desc).each do |s|
			seasons << [s.token, s.cwhl_id]
		end

		return seasons
	end

	def self.list
		seasons_info = []
		self.where(is_regular_season: true, is_playoffs: true).order(cwhl_id: :desc).each do |s|
			Game.where(season_id: s.cwhl_id).count > 0 ? collected = "has been retrieved" : collected = "is missing"
			seasons_info << "#{s.abbreviation} #{collected}"
		end

		seasons_info.each do |s|
			puts s
		end
	end

	def self.scrape_all_seasons
		require 'open-uri'
		url = "https://lscluster.hockeytech.com/feed/index.php?feed=statviewfeed&view=bootstrap&season=18&game_id=&pageName=schedule&key=eb62889ab4dfb04e&client_code=cwhl&site_id=2&league_id=1&league_code=&lang=en&callback=angular.callbacks._0"
		doc = JSON.parse(Nokogiri::HTML(open(url)).to_s[/\(\{(.*?)\}\)/].tr('(','').tr(')',''))

		seasons_data = doc["seasons"]
		seasons = {}

		seasons_data.each do |season|
			s_id = season["id"].to_i
			s_name = season["name"]

			is_playoffs = false
			is_regular_season = false
			is_allstar_game = false
			is_exhibition = false

			next if Season.find_by(cwhl_id: s_id)

			if !s_name[/Exhibition/].nil?
				year_start = year_end = nil
				abbreviation = "EX"
				is_exhibition = true
			elsif !s_name[/Regular/].nil?
				year_start = s_name[/(.*?)\-/].to_i
				year_end = year_start + 1
				abbreviation = "#{year_start.to_s[2..3]}-#{year_end.to_s[2..3]}"
				is_regular_season = true
			elsif !s_name[/Playoffs/].nil?
				year_start = year_end = s_name[/(.*?) /].to_i
				abbreviation = "#{year_start.to_s[2..3]}PO"
				is_playoffs = true
			elsif !s_name[/All-Star/].nil?
				is_allstar_game = true
				year_start = year_end = s_name[/(.*?) /].to_i
				abbreviation = "#{year_start.to_s[2..3]}AS"
			end

			
			date_url = "https://lscluster.hockeytech.com/feed/index.php?feed=statviewfeed&view=schedule&team=-1&season=#{s_id}&month=-1&location=homeaway&key=eb62889ab4dfb04e&client_code=cwhl&site_id=2&league_id=1&division_id=-1&lang=en&callback=angular.callbacks._1"
			s_doc = JSON.parse(Nokogiri::HTML(open(date_url)).to_s[/\(\[(.*?)\]\)/].tr('(','').tr(')',''))
			next if s_doc.first["sections"].first["data"] == [] # If new season hasn't been fully added yet, skip it
			
			start_date = Date.parse(s_doc.first["sections"].first["data"].first["row"]["date_with_day"].to_s + " " + year_start.to_s)
			end_date = Date.parse(s_doc.first["sections"].first["data"].last["row"]["date_with_day"].to_s + " " + year_end.to_s)
			
			Season.where(cwhl_id: s_id).first_or_create.update_attributes(name: s_name,
																		year_start: year_start,
																		year_end: year_end,
																		start_date: start_date,
																		end_date: end_date,
																		abbreviation: abbreviation,
																		is_regular_season: is_regular_season,
																		is_playoffs: is_playoffs,
																		is_allstar_game: is_allstar_game,
																		is_exhibition: is_exhibition)
		end
		
		Season.all.update_all(current_season: false)
		Season.where(is_regular_season: true).order(cwhl_id: :desc).first.update_attributes(current_season: true)
	end
end
