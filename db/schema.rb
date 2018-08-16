# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180816153352) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "coached_games", force: :cascade do |t|
    t.integer "team_id"
    t.integer "season_id"
    t.integer "game_id"
    t.integer "coach_id"
    t.string "first_name"
    t.string "last_name"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "coaches", force: :cascade do |t|
    t.integer "team_id"
    t.integer "season_id"
    t.string "first_name"
    t.string "last_name"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_id"
  end

  create_table "divisions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cwhl_division_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "cwhl_game_id"
    t.datetime "game_date"
    t.integer "game_number"
    t.string "venue"
    t.integer "attendance"
    t.string "start_time"
    t.string "end_time"
    t.integer "duration"
    t.integer "home_team_id"
    t.integer "visiting_team_id"
    t.boolean "overtime"
    t.boolean "shootout"
    t.integer "periods"
    t.integer "home_score"
    t.integer "visitor_score"
    t.integer "season_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "first_period_home_goals"
    t.integer "first_period_home_shots"
    t.integer "first_period_visitor_goals"
    t.integer "first_period_visitor_shots"
    t.integer "second_period_home_goals"
    t.integer "second_period_home_shots"
    t.integer "second_period_visitor_goals"
    t.integer "second_period_visitor_shots"
    t.integer "third_period_home_goals"
    t.integer "third_period_home_shots"
    t.integer "third_period_visitor_goals"
    t.integer "third_period_visitor_shots"
    t.integer "home_shots"
    t.integer "visitor_shots"
    t.integer "winning_team_id"
    t.integer "goals_count"
    t.string "home_abbreviation"
    t.string "visitor_abbreviation"
    t.boolean "is_playoffs"
    t.integer "home_total_shots"
    t.integer "visitor_total_shots"
    t.string "game_name"
    t.index ["cwhl_game_id"], name: "index_games_on_cwhl_game_id"
  end

  create_table "goalie_game_statlines", force: :cascade do |t|
    t.integer "player_id"
    t.integer "team_id"
    t.integer "season_id"
    t.integer "game_id"
    t.string "first_name"
    t.string "last_name"
    t.string "position"
    t.integer "number"
    t.string "captaincy"
    t.integer "shots_against"
    t.integer "goals_against"
    t.integer "saves"
    t.integer "time_on_ice"
    t.boolean "starting"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "goals"
    t.integer "points"
    t.integer "assists"
    t.datetime "game_date"
    t.string "game_name"
    t.decimal "save_percent", precision: 6, scale: 3, default: "0.0"
    t.index ["game_id"], name: "index_goalie_game_statlines_on_game_id"
  end

  create_table "goalies", force: :cascade do |t|
    t.integer "player_id"
    t.integer "team_id"
    t.integer "season_id"
    t.string "first_name"
    t.string "last_name"
    t.string "position"
    t.integer "number"
    t.string "captaincy"
    t.integer "shots_against"
    t.integer "goals_against"
    t.integer "saves"
    t.integer "time_on_ice"
    t.integer "goals"
    t.integer "assists"
    t.integer "points"
    t.decimal "shots_against_pg", precision: 5, scale: 2, default: "0.0"
    t.decimal "goals_against_average", precision: 5, scale: 2, default: "0.0"
    t.decimal "save_percentage", precision: 6, scale: 3, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "penalty_minutes"
    t.integer "penalties"
    t.integer "games_played"
    t.integer "penalty_shot_goals_against"
    t.integer "shootout_attempts"
    t.integer "shootout_goals_against"
    t.decimal "shootout_percent", precision: 5, scale: 3, default: "0.0"
    t.integer "penalty_shot_attempts"
    t.string "shoots"
    t.string "height"
    t.integer "weight"
    t.date "dob"
    t.decimal "season_age", precision: 5, scale: 2
    t.boolean "is_rookie"
    t.decimal "saves_pg", precision: 5, scale: 2
    t.string "season_abbreviation"
    t.string "team_abbreviation"
    t.string "full_name"
  end

  create_table "goals", force: :cascade do |t|
    t.integer "game_id"
    t.integer "team_id"
    t.integer "season_id"
    t.integer "goalscorer_id"
    t.integer "a1_id"
    t.integer "a2_id"
    t.integer "opposing_team_id"
    t.integer "team_score"
    t.integer "opposing_team_score"
    t.integer "period"
    t.integer "time"
    t.boolean "is_empty_net"
    t.boolean "is_powerplay"
    t.boolean "is_shorthanded"
    t.boolean "is_penalty_shot"
    t.integer "team_player_count"
    t.integer "opposing_team_player_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_time_elapsed"
    t.index ["game_id"], name: "index_goals_on_game_id"
  end

  create_table "on_ice_skaters", force: :cascade do |t|
    t.integer "goal_id"
    t.integer "game_id"
    t.integer "season_id"
    t.integer "player_id"
    t.integer "team_id"
    t.boolean "on_scoring_team"
    t.boolean "is_powerplay"
    t.boolean "is_empty_net"
    t.boolean "is_shorthanded"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "teammate_count"
    t.integer "opposing_skaters_count"
    t.integer "period"
    t.integer "time"
    t.datetime "game_date"
    t.boolean "received_point"
    t.index ["goal_id"], name: "index_on_ice_skaters_on_goal_id"
    t.index ["player_id", "season_id", "team_id"], name: "index_on_ice_skaters_on_player_id_and_season_id_and_team_id"
    t.index ["player_id"], name: "index_on_ice_skaters_on_player_id"
  end

  create_table "overtimes", force: :cascade do |t|
    t.integer "game_id"
    t.integer "cwhl_game_id"
    t.integer "season_id"
    t.integer "home_team_id"
    t.integer "visiting_team_id"
    t.integer "overtime_number"
    t.integer "home_shots"
    t.integer "home_goals"
    t.integer "visitor_shots"
    t.integer "visitor_goals"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "penalties", force: :cascade do |t|
    t.integer "game_id"
    t.integer "season_id"
    t.integer "team_id"
    t.integer "player_id"
    t.integer "serving_player_id"
    t.integer "drawing_team_id"
    t.integer "period"
    t.integer "time"
    t.string "description"
    t.integer "team_score"
    t.integer "opposing_team_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "duration"
    t.string "game_name"
    t.datetime "game_date"
    t.integer "game_time_elapsed"
    t.boolean "is_minor"
    t.boolean "is_double_minor"
    t.boolean "is_major"
    t.boolean "is_fight"
    t.boolean "is_game_misconduct"
    t.boolean "is_misconduct"
    t.index ["game_id"], name: "index_penalties_on_game_id"
  end

  create_table "penalty_shots", force: :cascade do |t|
    t.integer "player_id"
    t.integer "game_id"
    t.integer "season_id"
    t.integer "goalie_id"
    t.boolean "scored"
    t.integer "team_id"
    t.integer "defending_team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "time"
    t.integer "period"
  end

  create_table "player_game_statlines", force: :cascade do |t|
    t.integer "game_id"
    t.integer "team_id"
    t.integer "player_id"
    t.string "first_name"
    t.string "last_name"
    t.integer "number"
    t.string "position"
    t.integer "goals"
    t.integer "a1"
    t.integer "a2"
    t.integer "shots"
    t.string "captaincy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "season_id"
    t.integer "ev_goals"
    t.integer "ev_a1"
    t.integer "ev_a2"
    t.integer "pp_goals"
    t.integer "pp_a1"
    t.integer "pp_a2"
    t.integer "sh_goals"
    t.integer "sh_a1"
    t.integer "sh_a2"
    t.integer "ps_goals"
    t.integer "points"
    t.integer "ev_points"
    t.integer "pp_points"
    t.integer "sh_points"
    t.datetime "game_date"
    t.string "game_name"
    t.integer "opposing_team_id"
    t.boolean "is_home_game"
    t.index ["game_id"], name: "index_player_game_statlines_on_game_id"
    t.index ["player_id", "season_id", "team_id"], name: "index_on_pgs_player_season_team"
  end

  create_table "players", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cwhl_id"
    t.string "first_name"
    t.string "last_name"
    t.string "position"
    t.date "birthdate"
    t.string "shoots"
    t.string "height"
    t.integer "weight"
    t.index ["cwhl_id"], name: "index_players_on_cwhl_id"
  end

  create_table "referees", force: :cascade do |t|
    t.integer "number"
    t.string "position"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_id"
    t.integer "season_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.integer "year_start"
    t.integer "year_end"
    t.string "name"
    t.integer "cwhl_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_playoffs"
    t.boolean "current_season"
    t.boolean "is_allstar_game"
    t.date "end_date"
    t.date "start_date"
    t.string "abbreviation"
    t.boolean "is_regular_season"
    t.boolean "is_exhibition"
  end

  create_table "series", force: :cascade do |t|
    t.integer "season_id"
    t.integer "games_played"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "team_id"
    t.integer "opposing_team_id"
    t.integer "wins"
    t.integer "losses"
    t.integer "gf"
    t.integer "ga"
    t.decimal "gf_p"
    t.integer "sf"
    t.integer "sa"
    t.decimal "sf_p"
    t.decimal "shooting_percent"
    t.decimal "save_percent"
    t.boolean "won_series"
    t.integer "round"
  end

  create_table "shootout_attempts", force: :cascade do |t|
    t.integer "game_id"
    t.integer "season_id"
    t.integer "team_id"
    t.integer "player_id"
    t.integer "goalie_id"
    t.boolean "scored"
    t.boolean "game_winner"
    t.integer "shot_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "defending_team_id"
    t.index ["game_id", "team_id"], name: "index_shootout_attempts_on_game_id_and_team_id"
  end

  create_table "skaters", force: :cascade do |t|
    t.integer "player_id"
    t.integer "team_id"
    t.integer "season_id"
    t.string "first_name"
    t.string "last_name"
    t.string "position"
    t.string "captain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "goals"
    t.integer "a1"
    t.integer "a2"
    t.integer "ev_goals"
    t.integer "ev_a1"
    t.integer "ev_a2"
    t.integer "pp_goals"
    t.integer "pp_a1"
    t.integer "pp_a2"
    t.integer "sh_goals"
    t.integer "sh_a1"
    t.integer "sh_a2"
    t.integer "shots"
    t.integer "points"
    t.integer "ev_points"
    t.integer "pp_points"
    t.integer "sh_points"
    t.integer "ps_goals"
    t.integer "ps_taken"
    t.integer "games_played"
    t.integer "penalties_taken"
    t.integer "penalty_minutes"
    t.integer "pr_points"
    t.integer "ev_pr_points"
    t.integer "pp_pr_points"
    t.integer "sh_pr_points"
    t.decimal "goals_pg", precision: 5, scale: 2
    t.decimal "a1_pg", precision: 5, scale: 2
    t.decimal "a2_pg", precision: 5, scale: 2
    t.decimal "points_pg", precision: 5, scale: 2
    t.decimal "ev_goals_pg", precision: 5, scale: 2
    t.decimal "ev_a1_pg", precision: 5, scale: 2
    t.decimal "ev_a2_pg", precision: 5, scale: 2
    t.decimal "ev_points_pg", precision: 5, scale: 2
    t.decimal "pp_goals_pg", precision: 5, scale: 2
    t.decimal "pp_a1_pg", precision: 5, scale: 2
    t.decimal "pp_a2_pg", precision: 5, scale: 2
    t.decimal "sh_goals_pg", precision: 5, scale: 2
    t.decimal "sh_a1_pg", precision: 5, scale: 2
    t.decimal "sh_a2_pg", precision: 5, scale: 2
    t.decimal "sh_points_pg", precision: 5, scale: 2
    t.decimal "shots_pg", precision: 5, scale: 2
    t.decimal "pr_points_pg", precision: 5, scale: 2
    t.decimal "ev_pr_points_pg", precision: 5, scale: 2
    t.decimal "pp_pr_points_pg", precision: 5, scale: 2
    t.decimal "sh_pr_points_pg", precision: 5, scale: 2
    t.decimal "pp_points_pg", precision: 5, scale: 2
    t.decimal "penalty_minutes_pg", precision: 5, scale: 2
    t.decimal "shooting_percent", precision: 6, scale: 3
    t.decimal "season_age", precision: 5, scale: 2
    t.date "dob"
    t.string "shoots"
    t.string "height"
    t.integer "weight"
    t.boolean "is_rookie"
    t.integer "number"
    t.integer "shootout_attempts"
    t.integer "shootout_goals"
    t.decimal "shootout_percent", precision: 5, scale: 3
    t.integer "shootout_game_winners"
    t.decimal "ps_percent", precision: 5, scale: 2
    t.integer "gf_6v5"
    t.integer "ga_6v5"
    t.decimal "gf_p_6v5", precision: 5, scale: 2
    t.integer "gf_5v6"
    t.integer "ga_5v6"
    t.decimal "gf_p_5v6", precision: 5, scale: 2
    t.integer "gf_5v5"
    t.integer "ga_5v5"
    t.decimal "gf_p_5v5", precision: 5, scale: 2
    t.integer "gf_5v4"
    t.integer "ga_5v4"
    t.decimal "gf_p_5v4", precision: 5, scale: 2
    t.integer "gf_4v5"
    t.integer "ga_4v5"
    t.decimal "gf_p_4v5", precision: 5, scale: 2
    t.integer "gf_4v3"
    t.integer "ga_4v3"
    t.decimal "gf_p_4v3", precision: 5, scale: 2
    t.integer "gf_3v4"
    t.integer "ga_3v4"
    t.decimal "gf_p_3v4", precision: 5, scale: 2
    t.integer "gf_3v3"
    t.integer "ga_3v3"
    t.decimal "gf_p_3v3", precision: 5, scale: 2
    t.integer "gf_5v3"
    t.integer "ga_5v3"
    t.decimal "gf_p_5v3", precision: 5, scale: 2
    t.integer "gf_3v5"
    t.integer "ga_3v5"
    t.decimal "gf_p_3v5", precision: 5, scale: 2
    t.integer "gf_6v3"
    t.integer "ga_6v3"
    t.decimal "gf_p_6v3", precision: 5, scale: 2
    t.integer "gf_3v6"
    t.integer "ga_3v6"
    t.decimal "gf_p_3v6", precision: 5, scale: 2
    t.integer "gf_6v4"
    t.integer "ga_6v4"
    t.decimal "gf_p_6v4"
    t.integer "gf_4v6"
    t.integer "ga_4v6"
    t.decimal "gf_p_4v6"
    t.integer "gf_4v4"
    t.integer "ga_4v4"
    t.decimal "gf_p_4v4", precision: 5, scale: 2
    t.integer "gf_es"
    t.integer "ga_es"
    t.decimal "gf_p_es", precision: 5, scale: 2
    t.integer "gf_pp"
    t.integer "ga_pp"
    t.decimal "gf_p_pp", precision: 5, scale: 2
    t.integer "gf_pk"
    t.integer "ga_pk"
    t.decimal "gf_p_pk", precision: 5, scale: 2
    t.decimal "gf_es_pg", precision: 5, scale: 2
    t.decimal "ga_es_pg", precision: 5, scale: 2
    t.decimal "gf_pp_pg", precision: 5, scale: 2
    t.decimal "ga_pp_pg", precision: 5, scale: 2
    t.decimal "gf_pk_pg", precision: 5, scale: 2
    t.decimal "ga_pk_pg", precision: 5, scale: 2
    t.integer "gf_enf"
    t.integer "ga_enf"
    t.decimal "gf_p_enf", precision: 5, scale: 2
    t.integer "gf_ena"
    t.integer "ga_ena"
    t.decimal "gf_p_ena", precision: 5, scale: 2
    t.integer "en_goals"
    t.integer "en_a1"
    t.integer "en_a2"
    t.integer "en_points"
    t.decimal "gf_es_rel", precision: 5, scale: 2
    t.decimal "gf_pp_rel", precision: 5, scale: 2
    t.decimal "gf_pk_rel", precision: 5, scale: 2
    t.decimal "gf_5v5_rel", precision: 5, scale: 2
    t.decimal "as_ipp", precision: 5, scale: 2
    t.decimal "es_ipp", precision: 5, scale: 2
    t.decimal "pp_ipp", precision: 5, scale: 2
    t.integer "minors"
    t.decimal "minors_pg", precision: 5, scale: 2, default: "0.0"
    t.integer "double_minors"
    t.decimal "double_minors_pg", precision: 5, scale: 2, default: "0.0"
    t.integer "majors"
    t.decimal "majors_pg", precision: 5, scale: 2, default: "0.0"
    t.integer "fights"
    t.decimal "fights_pg", precision: 5, scale: 2, default: "0.0"
    t.integer "misconducts"
    t.decimal "misconducts_pg", precision: 5, scale: 2, default: "0.0"
    t.integer "game_misconducts"
    t.decimal "game_misconducts_pg", precision: 5, scale: 2, default: "0.0"
    t.string "team_abbreviation"
    t.string "full_name"
    t.string "season_abbreviation"
    t.index ["player_id", "season_id", "team_id"], name: "index_skaters_on_player_id_and_season_id_and_team_id"
    t.index ["season_id"], name: "index_skaters_on_season_id"
  end

  create_table "stars", force: :cascade do |t|
    t.integer "game_id"
    t.integer "season_id"
    t.integer "team_id"
    t.integer "player_id"
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "team_game_statlines", force: :cascade do |t|
    t.integer "game_id"
    t.integer "season_id"
    t.integer "team_id"
    t.string "abbreviation"
    t.datetime "game_date"
    t.boolean "home_team"
    t.boolean "overtime"
    t.boolean "shootout"
    t.integer "goals_for"
    t.integer "goals_against"
    t.integer "p1_goals"
    t.integer "p2_goals"
    t.integer "p3_goals"
    t.integer "p1_goals_against"
    t.integer "p2_goals_against"
    t.integer "p3_goals_against"
    t.integer "shots_for"
    t.integer "shots_against"
    t.integer "p1_shots"
    t.integer "p2_shots"
    t.integer "p3_shots"
    t.integer "p1_shots_against"
    t.integer "p2_shots_against"
    t.integer "p3_shots_against"
    t.integer "ev_goals"
    t.integer "ev_goals_against"
    t.integer "pp_goals"
    t.integer "pp_goals_against"
    t.integer "sh_goals"
    t.integer "sh_goals_against"
    t.integer "en_goals"
    t.integer "en_goals_against"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "so_goals"
    t.integer "so_goals_against"
    t.integer "ot_goals"
    t.integer "ot_goals_against"
    t.integer "ot_shots"
    t.integer "ot_shots_against"
    t.integer "ot_periods"
    t.boolean "won"
    t.integer "opponent_id"
    t.string "opponent_abbreviation"
  end

  create_table "team_statlines", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.string "abbreviation"
    t.integer "division_id"
    t.integer "team_code"
    t.integer "season_id"
    t.integer "games_played"
    t.integer "wins"
    t.integer "losses"
    t.integer "ot_losses"
    t.integer "so_losses"
    t.integer "points"
    t.decimal "points_percentage", precision: 5, scale: 2
    t.integer "row"
    t.integer "goals_for"
    t.integer "goals_against"
    t.integer "ev_goals_for"
    t.integer "ev_goals_against"
    t.integer "sh_goals_for"
    t.integer "sh_goals_against"
    t.integer "pp_goals_for"
    t.integer "pp_goals_against"
    t.integer "penalty_minutes"
    t.integer "shots"
    t.integer "first_period_shots"
    t.integer "second_period_shots"
    t.integer "third_period_shots"
    t.integer "ot_shots"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "shots_against"
    t.decimal "shots_pg", precision: 5, scale: 2
    t.decimal "shots_against_pg", precision: 5, scale: 2
    t.decimal "shots_percent", precision: 6, scale: 3
    t.integer "ot_wins"
    t.integer "so_wins"
    t.decimal "first_period_shots_pg", precision: 5, scale: 2
    t.decimal "second_period_shots_pg", precision: 5, scale: 2
    t.decimal "third_period_shots_pg", precision: 5, scale: 2
    t.decimal "ot_period_shots_pg", precision: 5, scale: 2
    t.integer "first_period_goals"
    t.integer "second_period_goals"
    t.integer "third_period_goals"
    t.integer "ot_period_goals"
    t.decimal "first_period_goals_pg", precision: 5, scale: 2
    t.decimal "second_period_goals_pg", precision: 5, scale: 2
    t.decimal "third_period_goals_pg", precision: 5, scale: 2
    t.decimal "ot_period_goals_pg", precision: 5, scale: 2
    t.decimal "goals_for_pg", precision: 5, scale: 2
    t.decimal "goals_against_pg", precision: 5, scale: 2
    t.decimal "ev_goals_for_pg", precision: 5, scale: 2
    t.decimal "ev_goals_against_pg", precision: 5, scale: 2
    t.decimal "pp_goals_for_pg", precision: 5, scale: 2
    t.decimal "pp_goals_against_pg", precision: 5, scale: 2
    t.decimal "sh_goals_for_pg", precision: 5, scale: 2
    t.decimal "sh_goals_against_pg", precision: 5, scale: 2
    t.integer "shootout_attempts"
    t.integer "shootout_goals"
    t.decimal "shootout_percent", precision: 5, scale: 3
    t.integer "team_id"
    t.integer "ot_periods"
    t.decimal "goals_percent", precision: 5, scale: 2
    t.decimal "ev_goals_percent", precision: 5, scale: 2
    t.decimal "pdo", precision: 5, scale: 2
    t.decimal "shooting_percent", precision: 5, scale: 2
    t.decimal "save_percent", precision: 5, scale: 2
    t.integer "es_on_ice_gf"
    t.integer "es_on_ice_ga"
    t.integer "pp_on_ice_gf"
    t.integer "pp_on_ice_ga"
    t.integer "pk_on_ice_gf"
    t.integer "pk_on_ice_ga"
    t.integer "en_on_ice_gf"
    t.integer "en_on_ice_ga"
    t.integer "gf_6v5"
    t.integer "ga_6v5"
    t.integer "gf_5v6"
    t.integer "ga_5v6"
    t.integer "gf_5v5"
    t.integer "ga_5v5"
    t.decimal "gf_p_5v5", precision: 5, scale: 2
    t.integer "gf_5v4"
    t.integer "ga_5v4"
    t.integer "gf_4v5"
    t.integer "ga_4v5"
    t.integer "gf_4v4"
    t.integer "ga_4v4"
    t.decimal "gf_p_4v4", precision: 5, scale: 2
    t.integer "gf_4v3"
    t.integer "ga_4v3"
    t.integer "gf_3v4"
    t.integer "ga_3v4"
    t.integer "gf_3v3"
    t.integer "ga_3v3"
    t.decimal "gf_p_3v3", precision: 5, scale: 2
    t.integer "gf_5v3"
    t.integer "ga_5v3"
    t.integer "gf_3v5"
    t.integer "ga_3v5"
    t.integer "gf_6v3"
    t.integer "ga_6v3"
    t.integer "gf_3v6"
    t.integer "ga_3v6"
    t.integer "gf_6v4"
    t.integer "ga_6v4"
    t.integer "gf_4v6"
    t.integer "ga_4v6"
    t.integer "minors"
    t.decimal "minors_pg", precision: 5, scale: 2, default: "0.0"
    t.integer "double_minors"
    t.decimal "double_minors_pg", precision: 5, scale: 2, default: "0.0"
    t.integer "majors"
    t.decimal "majors_pg", precision: 5, scale: 2, default: "0.0"
    t.integer "fights"
    t.decimal "fights_pg", precision: 5, scale: 2, default: "0.0"
    t.integer "misconducts"
    t.decimal "misconducts_pg", precision: 5, scale: 2, default: "0.0"
    t.integer "game_misconducts"
    t.decimal "game_misconducts_pg", precision: 5, scale: 2, default: "0.0"
    t.string "full_name"
    t.string "season_abbreviation"
    t.index ["team_code"], name: "index_team_statlines_on_team_code"
  end

  create_table "teams", force: :cascade do |t|
    t.string "city"
    t.string "game_file_city"
    t.string "name"
    t.string "abbreviation"
    t.integer "division_id"
    t.integer "team_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "logo_url"
    t.integer "minors"
    t.decimal "minors_pg", precision: 5, scale: 2, default: "0.0"
    t.integer "double_minors"
    t.decimal "double_minors_pg", precision: 5, scale: 2, default: "0.0"
    t.integer "majors"
    t.decimal "majors_pg", precision: 5, scale: 2, default: "0.0"
    t.integer "fights"
    t.decimal "fights_pg", precision: 5, scale: 2, default: "0.0"
    t.integer "misconducts"
    t.decimal "misconducts_pg", precision: 5, scale: 2, default: "0.0"
    t.integer "game_misconducts"
    t.decimal "game_misconducts_pg", precision: 5, scale: 2, default: "0.0"
  end

end
