Rails.application.routes.draw do

	root 'static_pages#home'

	get '/games', to: 'games#index'
	get '/skaters', to: 'skaters#index'
	get '/teams', to: 'teams#index'
  get '/about', to: 'static_pages#about'
	get '/search', to: 'static_pages#search'
	get '/player_info', to: 'players#index', defaults: { format: :csv }
	
	get '/google5eb2aada44affd0e', to: proc { |env| [200, {}, ["google-site-verification: google5eb2aada44affd0e.html"]] }

  resources :games, only: [:index, :show]
  resources :skaters, only: [:index]
  resources :goalies, only: [:index]
  resources :players, only: [:show] do
		member do
			get 'goal_breakdown'
			get 'monthly_breakdown'
			get 'linemates'
			get 'opposition_breakdown'
		end
	end

	resources :teams, only: [:index, :show] do
		member do
			get 'penalties'
			get 'roster'
		end
	end

  if Rails.env.development?
		get '/test_daily_scrape', to: 'scraper#test_daily_scrape'
    get '/query', to: 'static_pages#query'
    get '/monthly_totals', to: 'skaters#monthly_totals'
    get '/select_dates', to: 'scraper#select_dates'
    get '/scrape_test', to: 'scraper#scrape_test'
    get '/scrape_games', to: 'scraper#scrape_games'
    get '/scrape_game', to: 'scraper#scrape_game'
		get '/on_ice_goals', to: 'scraper#on_ice_goals'
		get '/penalties', to: 'scraper#penalties'
		get '/update_goalies', to: 'scraper#update_goalies'
		get '/update_skaters', to: 'scraper#update_skaters'
		get '/profile_test', to: 'scraper#profile_test'
	end
	
end
