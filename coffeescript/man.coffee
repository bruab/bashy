# Man class stores manual entries for commands
# This exists just to keep BashyOS from getting too bloated
class Man
	constructor: ->
		@entries = {
			"cd": "\ncd - move to a new dir\n" +
			      "\nUSAGE\n\tcd [dir]\n" +
			      "\tType 'cd /' to go to the top.\n" +
			      "\tType 'cd' by itself to go home.\n" +
			      "\tType 'cd ..' to go up one level.\n",
			"pwd": "\npwd - tell what dir you're in\n" +
			       "\nUSAGE\n\tpwd\n"
			"man": "\nman - explain how commands work\n" +
			       "\nUSAGE\n\tman <command>\n" +
			       "\tType 'man cd' to learn about the 'cd' command\n"
			"ls": "This command tells you the contents of a dir.\n" +
			      "Type 'ls' by itself to see the contents of your " +
			      "current working dir.\n" +
			      "Type 'ls' followed by a path to see the contents of " +
			      "that dir",
			"cat": "\ncat - show the contents of a file\n" +
			       "\nUSAGE\n\tcat <file>\n"
			"head": "\nhead - show the first part of a file\n" +
				"\nUSAGE\n\thead <file>\n"
			"tail": "\ntail - show the last part of a file\n" +
				"\nUSAGE\n\ttail <file>\n"
			"wc": "\nwc - count the number of lines, words and characters in a file.\n" +
			      "\nUSAGE\n\twc <file>\n"
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
