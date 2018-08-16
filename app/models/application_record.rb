class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.calculate_stats(season_id)
    games = Game.where(season_id: season_id).count > 0 ? Game.where(season_id: season_id) : Game.all
    Player.scrape_ages()
  	Player.scrape_rookies(0)
  	Team.update_teams(games)
  	Skater.update_skaters(games)
  	Goalie.update_goalies(games)
  end
end
