desc "Scrape the games played on the previous day"
task :daily_scrape => :environment do
  date = 12.hours.ago.to_datetime
  puts "Starting Daily Scrape for #{date.strftime("%m-%d-%y")}..."
  start_time = Time.now
  Game.scrape_range_of_games(date, date)
  puts "Ending Daily Scrape for #{date.strftime("%m-%d-%y")}"
end
