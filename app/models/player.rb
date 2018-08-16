class Player < ApplicationRecord
	validates :cwhl_id, uniqueness: true
	has_many :seasons, 	foreign_key: :player_id,
											primary_key: :cwhl_id,
											class_name: "Skater",
											dependent: :destroy

	def full_name
		return self.first_name + " " + self.last_name
	end

	def age
		dob = self.birthdate
	  now = Time.now.utc.to_date
	  now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
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

	def self.scrape_ages
		require 'open-uri'

		players = Skater.where(season_age: nil)
		players.each do |player|
			profile = Player.find_by(cwhl_id: player.player_id)
			season = Season.find_by(cwhl_id: player.season_id)

			season = Season.find_by(is_regular_season: true, year_end: season.year_start) if season.is_playoffs == true # If it's the playoffs set age based on regular season start date
			url = "https://lscluster.hockeytech.com/feed/index.php?feed=statviewfeed&view=player&player_id=#{player.player_id}&season_id=#{season.cwhl_id}&site_id=2&key=eb62889ab4dfb04e&client_code=cwhl&league_id=&lang=en&statsType=standard&callback=angular.callbacks._1"

			next if season == nil || season.cwhl_id == 45 || season.cwhl_id == 58 # Skip If Exhibition Game Or Broken

			doc = Nokogiri::HTML(open(url))
			player_info = doc.to_s[/\"info\"(.*?)\"profileImage\"/]
			shoots = player_info[/\"shoots\"(.*?)\,/].split(':')[1].tr('"', "").tr(',', "")
			height = player_info[/\"height\"(.*?)\,/].split(':')[1].tr('"', "").tr(',', "")
			weight = player_info[/\"weight\"(.*?)\,/].split(':')[1].tr('"', "").tr(',', "")
			birthdate = player_info[/\"birthDate\"(.*?)\,/].split(':')[1].tr('"', "").tr(',', "")

			if birthdate == "0000-00-00" || birthdate == "" || birthdate == nil
				season_age = 0
				birthdate = "1800-01-01"
			else
				season_age = get_age_at_date(season.start_date, Date.parse(birthdate))
			end

			player.update_attributes(shoots: shoots,
																height: height,
																weight: weight,
																dob: Date.parse(birthdate),
																season_age: season_age)

			profile.update_attributes(shoots: shoots,
																height: height,
																weight: weight,
																birthdate: Date.parse(birthdate))
		end

		goalies = Goalie.where(season_age: nil)

		goalies.each do |player|
			profile = Player.find_by(cwhl_id: player.player_id)
			
			season = Season.find_by(cwhl_id: player.season_id)
			season = Season.find_by(is_regular_season: true, year_end: season.year_start) if season.is_playoffs == true # If it's the playoffs set age based on regular season start date
			
			next if season == nil || season.cwhl_id == 45 || season.cwhl_id == 58 # Skip If Exhibition Game Or Broken

			url = "https://lscluster.hockeytech.com/feed/index.php?feed=statviewfeed&view=player&player_id=#{player.player_id}&season_id=#{season.cwhl_id}&site_id=2&key=eb62889ab4dfb04e&client_code=cwhl&league_id=&lang=en&statsType=standard&callback=angular.callbacks._1"
			
			doc = Nokogiri::HTML(open(url))
			player_info = doc.to_s[/\"info\"(.*?)\"profileImage\"/]
			shoots = player_info[/\"shoots\"(.*?)\,/].split(':')[1].tr('"', "").tr(',', "")
			height = player_info[/\"height\"(.*?)\,/].split(':')[1].tr('"', "").tr(',', "")
			weight = player_info[/\"weight\"(.*?)\,/].split(':')[1].tr('"', "").tr(',', "")
			birthdate = player_info[/\"birthDate\"(.*?)\,/].split(':')[1].tr('"', "").tr(',', "")

			if birthdate == "0000-00-00" || birthdate == "" || birthdate == nil
				season_age = 0
				birthdate = "1800-01-01"
			else
				season_age = get_age_at_date(season.start_date, Date.parse(birthdate))
			end

			player.update_attributes(shoots: shoots,
																height: height,
																weight: weight,
																dob: Date.parse(birthdate),
																season_age: season_age)

			profile.update_attributes(shoots: shoots,
																height: height,
																weight: weight,
																birthdate: Date.parse(birthdate))
		end
	end

	def self.scrape_rookies()
		require 'open-uri'

		skaters = Skater.where(is_rookie: nil)
		goalies = Goalie.where(is_rookie: nil)
		team_statline_ids = []

		skaters.each do |s|
			team_statline_ids << s.team_statline.id
		end

		goalies.each do |g|
			team_statline_ids << g.team_statline.id
		end

		team_statline_ids.uniq!

		team_statline_ids.each do |team_statline_id|
			team = TeamStatline.find(team_statline_id)

			forwards_url = "https://lscluster.hockeytech.com/feed/index.php?feed=statviewfeed&view=players&season=#{team.season_id}&team=#{team.team_code}&position=forwards&rookies=1&statsType=standard&rosterstatus=undefined&site_id=2&first=0&limit=20&sort=points&league_id=1&lang=en&division=-1&key=eb62889ab4dfb04e&client_code=cwhl&league_id=1&callback=angular.callbacks._1"
			defensemen_url = "https://lscluster.hockeytech.com/feed/index.php?feed=statviewfeed&view=players&season=#{team.season_id}&team=#{team.team_code}&position=defencemen&rookies=1&statsType=standard&rosterstatus=undefined&site_id=2&first=0&limit=20&sort=points&league_id=1&lang=en&division=-1&key=eb62889ab4dfb04e&client_code=cwhl&league_id=1&callback=angular.callbacks._1"
			goalies_url = "https://lscluster.hockeytech.com/feed/index.php?feed=statviewfeed&view=players&season=#{team.season_id}&team=#{team.team_code}&position=goalies&rookies=1&statsType=standard&rosterstatus=undefined&site_id=2&first=0&limit=20&sort=gaa&league_id=1&lang=en&division=-1&qualified=qualified&key=eb62889ab4dfb04e&client_code=cwhl&league_id=1&callback=angular.callbacks._1"

			skaters = [forwards_url, defensemen_url]

			skaters.each do |url|
				doc = Nokogiri::HTML(open(url))
				if !doc.to_s[/data\:\[\]/].nil?
					break
				end
				player_data = doc.to_s[/\"data(.*?)\]\)/]
				players = player_data.scan(/\"player_id(.*?)\,/)

				players.each do |player|
					id = player.to_s[/\d+/]
					p = Skater.where(player_id: id, season_id: team.season_id)

					p.each do |u|
						u.update_attributes(is_rookie: true)
						u.save
					end
				end
			end

			doc = Nokogiri::HTML(open(goalies_url))
			if !doc.to_s[/data\:\[\]/].nil?
				break
			end
			player_data = doc.to_s[/\"data(.*?)\]\)/]
			players = player_data.scan(/\"player_id(.*?)\,/)

			players.each do |player|
				id = player.to_s[/\d+/]
				p = Goalie.where(player_id: id, season_id: team.season_id)

				p.each do |u|
					u.update_attributes(is_rookie: true)
					u.save
				end
			end
		end

		# Any players that weren't rookies update to false
		Skater.where(is_rookie: nil).update_all(is_rookie: false)
		Goalie.where(is_rookie: nil).update_all(is_rookie: false)
	end

	private
		def self.get_age_at_date(date, birthdate)
			BigDecimal.new((date - birthdate).to_i) / BigDecimal.new(365)
		end
end
