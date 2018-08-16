# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
	$('#goalies-table .active-link').closest('th').attr('id', 'active-th')
	active_column = $('#goalies-table .active-link').closest('th').index() + 1
	$('#goalies-table table tbody td:nth-child(' + active_column + ')').addClass('active-tcol')

	$("#goalie_select").selectize
		minimumInputLength: 2
