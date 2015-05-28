# Man class stores manual entries for commands
# This exists just to keep BashyOS from getting too bloated
class Man
	constructor: ->
		@entries = {
			"cd": "This command moves you around.\n" +
			      "Type 'cd /' to go to the top.\n" +
			      "Type 'cd' by itself to go home.\n" +
			      "Type 'cd ..' to go up one level.",
			"pwd": "This command gives your location.\n" +
			       "(Technically, it gives  the path\n" +
			       "to your current working directory.)",
			"man": "This command gives instructions\n" +
			       "on how commands work.\n" +
			       "Type 'man cd' to learn about the\n" +
			       "'cd' command",
			"ls": "This command tells you the contents of a directory.\n" +
			      "Type 'ls' by itself to see the contents of your " +
			      "current working directory.\n" +
			      "Type 'ls' followed by a path to see the contents of " +
			      "that directory",
			"cat": "This command displays a text file on the screen.",
			"head": "This command displays the first ten lines of a text file.",
			"tail": "This command displays the last ten lines of a text file.",
			"grep": "This command displays every line of a file that matches " +
			        "a pattern that you provide.",
			"sed": "This command allows you to change the contents of a text " +
			       "file by substituting one pattern for another."
		}

	# Take a command as a string; return [stdout, stderr]
	# Where stdout is manual entry if command is known;
	# stderr is an error message if command is not known
	getEntry: (command) ->
		[stdout, stderr] = ["", ""]
		# See if command is known
		if command of @entries
			stdout = @entries[command]
		else
			stderr = "No manual entry for #{command}"
		return [stdout, stderr]
