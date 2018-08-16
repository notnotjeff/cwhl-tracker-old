# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  show_legend = $("#show-legend")
  legend = $("#legend")
  show_legend.on 'click', ->
    legend.toggle()
    if (show_legend.text() == '[-] Hide Legend')
      show_legend.html('<span>[+] Show Legend</span>')
    else
      show_legend.html('<span>[-] Hide Legend</span>')