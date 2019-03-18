# frozen_string_literal: true

desc 'Scrape the games played on the previous day'

task daily_scrape: :environment do
  date = 12.hours.ago.to_datetime
  p "Starting Daily Scrape for #{date.strftime('%m-%d-%y')}..."
  Game.scrape_range_of_games(date, date)
  p "Ending Daily Scrape for #{date.strftime('%m-%d-%y')}"
end

task weekly_rescrape: :environment do
  end_date = 36.hours.ago.to_datetime
  start_date = 7.days.ago.to_datetime
  p "Starting Rescrape for date range: #{start_date.strftime('%m-%d-%y')} #{end_date.strftime('%m-%d-%y')}..."
  Game.scrape_range_of_games(start_date, end_date)
  p "Ending Rescrape for date range: #{start_date.strftime('%m-%d-%y')} #{end_date.strftime('%m-%d-%y')}"
end
