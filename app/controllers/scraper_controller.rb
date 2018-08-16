class ScraperController < ApplicationController
  def select_dates
    @seasons = Season.where(cwhl_id: Game.pluck(:season_id).uniq).order(cwhl_id: :desc)
  end

  def scrape_game
    time = Time.now
    game = "1017953"
    Game.scrape_game(game)
    Game.merge_games(time)
    redirect_to game_path(Game.find(game.to_i))
  end

  def scrape_games
  	if params[:season]
  		start_date = Season.find_by(cwhl_id: params[:season]).start_date
  		end_date = Season.find_by(cwhl_id: params[:season]).end_date
  	else
	  	start_date = Date.parse(params[:start_date])
	  	end_date = Date.parse(params[:end_date])
    end

  	Game.scrape_range_of_games(start_date, end_date)

		redirect_to root_url
	end

  def scrape_test
    # List of Game IDs
    regulation = 74
    extra_name_characters_i = 75
    extra_name_characters_e = 80

    # Game Select
    game_id = extra_name_characters_e
  	game_file = Game.scraper_test(game_id)

  	# Return Page With Game File Result
  	render json: game_file
  end

  def test_daily_scrape
    date = DateTime.parse("2017-10-14")
    Game.scrape_range_of_games(date, date)

    redirect_to root_url
  end

  def penalties
    @penalties = Penalty.select('distinct description, duration').collect { |p| [p.description, p.duration] }
    @penalties.sort!
  end

  def on_ice_goals
    players = Skater.all
    liljegren = Skater.find_by(season_id: 57, player_id: 6893)

    # player_on_ice_ga = OnIceSkater.where(season_id: player.season_id, player_id: player.player_id, on_scoring_team: false).count
    goals = []

    players.each do |player|
      Skater.update_skater(player.player_id, player.team_id, player.season_id, nil)
    end

    render plain: liljegren.to_yaml
  end

  def update_goalies
    goalies = Goalie.all
    goalies.each do |g|
      Goalie.update_goalie(g.player_id, g.team_id, g.season_id)
    end
    redirect_to root_url
  end

  def update_skaters
    Skater.update_all_skaters
  end
end
