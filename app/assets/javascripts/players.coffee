# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  $('#player-profile-table .active-link').closest('th').attr('id', 'active-th')
  profile_active_column = $('#player-profile-table .active-link').closest('th').index() + 1
  $('#player-profile-table table tbody td:nth-child(' + profile_active_column + ')').addClass('active-tcol')

  $('#player-game-breakdown .active-link').closest('th').attr('id', 'active-th')
  player_game_breakdown_active_column = $('#player-game-breakdown .active-link').closest('th').index() + 1
  $('#player-game-breakdown table tbody td:nth-child(' + player_game_breakdown_active_column + ')').addClass('active-tcol')

  $('#player-penalty-breakdown .active-link').closest('th').attr('id', 'active-th')
  player_penalty_breakdown_active_column = $('#player-penalty-breakdown .active-link').closest('th').index() + 1
  $('#player-penalty-breakdown table tbody td:nth-child(' + player_penalty_breakdown_active_column + ')').addClass('active-tcol')

  $('#player-on-ice-events .active-link').closest('th').attr('id', 'active-th')
  player_on_ice_events_active_column = $('#player-on-ice-events .active-link').closest('th').index() + 1
  $('#player-on-ice-events table tbody td:nth-child(' + player_on_ice_events_active_column + ')').addClass('active-tcol')
  
  $('#ob-table .active-link').closest('th').attr('id', 'active-th')
  ob_active_column = $('#ob-table .active-link').closest('th').index() + 1
  $('#ob-table table tbody td:nth-child(' + ob_active_column + ')').addClass('active-tcol')
