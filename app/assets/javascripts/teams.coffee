# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  $('#teams-table .active-link').closest('th').attr('id', 'active-th')
  teams_active_column = $('#teams-table .active-link').closest('th').index() + 1
  $('#teams-table table tbody td:nth-child(' + teams_active_column + ')').addClass('active-tcol')

  $('#team-profile .active-link').closest('th').attr('id', 'active-th')
  profile_active_column = $('#team-profile .active-link').closest('th').index() + 1
  $('#team-profile table tbody td:nth-child(' + profile_active_column + ')').addClass('active-tcol')

  $('#team-game-breakdown .active-link').closest('th').attr('id', 'active-th')
  team_game_breakdown_active_column = $('#team-game-breakdown .active-link').closest('th').index() + 1
  $('#team-game-breakdown table tbody td:nth-child(' + team_game_breakdown_active_column + ')').addClass('active-tcol')

  $('#teams-profile-penalties .active-link').closest('th').attr('id', 'active-th')
  teams_penalties_active_column = $('#teams-profile-penalties .active-link').closest('th').index() + 1
  $('#teams-profile-penalties table tbody td:nth-child(' + teams_penalties_active_column + ')').addClass('active-tcol')
