# Man class stores manual entries for commands
# This exists just to keep BashyOS from getting too bloated
class Man
	constructor: ->
		@entries = {
			"cd": "for navigate and stuff",
			"pwd": "tells you where you at",
			"man": "explains how commands work"
		}

	getEntry: (command) ->
		if command in @entries
			return @entries[command]
		else
			return "No manual entry for #{command}"
