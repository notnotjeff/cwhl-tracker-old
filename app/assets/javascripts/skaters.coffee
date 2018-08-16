# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:before-cache', ->

$(document).on 'turbolinks:load', ->
	$('#skaters-table .active-link').closest('th').attr('id', 'active-th')
	active_column = $('#skaters-table .active-link').closest('th').index() + 1
	$('#skaters-table table tbody td:nth-child(' + active_column + ')').addClass('active-tcol')

	$( "#seasons" ).selectize
    theme: "bootstrap"
	$( "#skater_select" ).selectize
		minimumInputLength: 2,
    theme: "bootstrap"
	$( "#teams" ).selectize
    theme: "bootstrap"
