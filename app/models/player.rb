class Player < ApplicationRecord
	require 'open-uri'

	validates :cwhl_id, uniqueness: true
	has_many :seasons, 	foreign_key: :player_id,
											primary_key: :cwhl_id,
											class_name: "Skater",
											dependent: :destroy

	def full_name
		return self.first_name + " " + self.last_name
	end

	def self.to_csv
		CSV.generate do |csv|
			column_names.delete("created_at")
			column_names.delete("updated_at")
			column_names.delete("id")
			csv << column_names
			all.each do |skater|
				csv << skater.attributes.values_at(*column_names)
			end
		end
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
		players = Skater.where(season_age: nil)
		players.each do |player|
			profile = Player.find_by(cwhl_id: player.player_id)
			season = Season.find_by(cwhl_id: player.season_id)
			season = Season.find_by(is_regular_season: true, year_end: season.year_start) if season.is_playoffs == true # If it's the playoffs set age based on regular season start date
			next if season == nil # Skip If Broken

			Player.update_profile(player.player_id, season, player, profile)
		end

		goalies = Goalie.where(season_age: nil)

		goalies.each do |player|
			profile = Player.find_by(cwhl_id: player.player_id)
			season = Season.find_by(cwhl_id: player.season_id)
			season = Season.find_by(is_regular_season: true, year_end: season.year_start) if season.is_playoffs == true # If it's the playoffs set age based on regular season start date
			next if season == nil # Skip If Broken

			Player.update_profile(player.player_id, season, player, profile)
		end
	end

	def self.update_profile(player_id, season, player_season, player_profile)
		url = "https://lscluster.hockeytech.com/feed/index.php?feed=statviewfeed&view=player&player_id=#{player_id}&season_id=#{season.cwhl_id}&site_id=2&key=eb62889ab4dfb04e&client_code=cwhl&league_id=&lang=en&statsType=standard&callback=angular.callbacks._1"
		doc = Nokogiri::HTML(open(url))
		
		player_info = JSON.parse(doc.to_s[/\"info\"(.*?)\"profileImage\"/][7..-1] + ':""}')
		shoots = player_profile.shoots.nil? ? player_info["shoots"] : player_profile.shoots
		height = player_profile.height.nil? ? player_info["height"] : player_profile.height
		weight = player_profile.weight.nil? ? player_info["weight"] : player_profile.weight
		birthdate = player_profile.birthdate.nil? ? player_info["birthDate"].to_s : player_profile.birthdate.to_s

		if birthdate == "0000-00-00" || birthdate == "" || birthdate == nil
			season_age = 0
		else
			season_age = get_age_at_date(season.start_date, Date.parse(birthdate))
		end

		player_season.update_attributes(shoots: shoots,
															height: height,
															weight: weight,
															dob: Date.parse(birthdate),
															season_age: season_age)
		player_profile.update_attributes(shoots: shoots,
															height: height,
															weight: weight,
															birthdate: Date.parse(birthdate))
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

	def self.scrape_missing_birthdates()
		players = Player.where(birthdate: "1800-01-01")

		ep_team_dir = {
			BRA: { id: "19359", name: "brampton-thunder" },
			BOS: { id: "19358", name: "boston-blades" },
			TOR: { id: "19362", name: "toronto-furies" },
			TORA: { id: "19449", name: "toronto-aeros" },
			CGY: { id: "19360", name: "calgary-inferno" },
			KRS: { id: "23914", name: "kunlun-red-star" },
			MTL: { id: "19361", name: "montreal-canadiennes" },
			MAR: { id: "19359", name: "markham-thunder" },
			ALB: { id: "19360", name: "alberta-honeybadgers" },
			BUR: { id: "19445", name: "burlington-barracudas" },
			VR: { id: "24370", name: "vanke-rays" },
			MIN: { id: "19483", name: "minnesota-whitecaps" }
		}
		
		players.each do |player|

			if player.seasons.count < 1
				player.update_attributes(birthdate: nil)
				puts "No seasons"
				next
			end

			season = player.seasons.order(season_id: :desc).first
			year = season.season_abbreviation[/PO/].nil? ? season.season_abbreviation.split('-').map { |s| "20#{s}" }.join("-") : "20#{season.season_abbreviation.tr('PO', '').to_i - 1}-20#{season.season_abbreviation.tr('PO', '')}"
			team_ep_info = year == "2010-2011" && season.team_abbreviation == "TOR" ? ep_team_dir[:TORA] : ep_team_dir[season.team_abbreviation.to_sym]
			url = "https://www.eliteprospects.com/team/#{team_ep_info[:id]}/#{team_ep_info[:name]}/#{year}"
			full_name = season.full_name

			full_name = "Alex Carpenter" if full_name == "Alexandra Carpenter"
			full_name = "Jiachao Xu" if full_name == "Jia Chao Xu"
			full_name = "Whitney Hannah Horne" if full_name == "Whitney Hannah-Horne"
			full_name = "Breehan Polci" if full_name == "Bree Polci"
			full_name = "Katerina Mrazova" if full_name == "Katka Mrazova"
			full_name = "Jennifer Sadler" if full_name == "Jen Sadler"
			full_name = "Geneviève Legault" if full_name == "Genevieve Legault"
			full_name = "Bobbi Jo Slusar" if full_name == "Bobbi-Jo Slusar"
			
			doc = Nokogiri::HTML(open(url))

			doc.css('.roster tr').each do |row|
				found = false
				if row.css('td').count > 8
					player_name = row.css('.sorted span a').text
					if !player_name[/#{full_name}/].nil?
						height = row.css('.height').text.strip
						weight = row.css('.weight').text.strip
						shoots = row.css('.shoots').text.strip

						profile_url = row.css('.sorted span a')[0]['href']
						profile_doc = Nokogiri::HTML(open(profile_url))

						birthdate = profile_doc.css('body > section.main_content.clearfix > div > div.content_left > div.innerwrapper > div:nth-child(1) > div > div.col-md-8.col-md-pull-4 > section > div.table-view > div.row> div.col-sm-7.pad-right-0 > ul > li:nth-child(1) > div.col-xs-8.fac-lbl-dark').text.strip
						
						player.update_attributes(height: height, weight: weight, shoots: shoots, birthdate: birthdate)
					end
				end
			end
		end
	end

	private
		def self.get_age_at_date(date, birthdate)
			BigDecimal.new((date - birthdate).to_i) / BigDecimal.new(365)
		end

		def self.get_info_for_unknown_players(player_id)
			if player_id == 479 # Sabrina Harbec
				shoots = "L"
				height = '5' + "'" + '8' + '"'
				weight = 150
				birthdate = "1985-03-20"
			elsif player_id == 432 # Erika Lawler
				shoots = "R"
				height = '4' + "'" + '11' + '"'
				weight = 134
				birthdate = "1987-02-05"
			else 
				shoots = ""
				height = ""
				weight = 0
				birthdate = "1980-01-01"
			end

			return shoots, height, weight, birthdate
		end
end
