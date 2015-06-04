# Man class stores manual entries for commands
# This exists just to keep BashyOS from getting too bloated
class Man
	constructor: ->
		@entries = {
			"cd": "\ncd - move to a new dir\n" +
			      "\nUSAGE\n\tcd [DIR]\n" +
			      "\tType 'cd /' to go to the top.\n" +
			      "\tType 'cd' by itself to go home.\n" +
			      "\tType 'cd ..' to go up one level.\n",
			"pwd": "\npwd - tell what dir you're in\n" +
			       "\nUSAGE\n\tpwd\n"
			"man": "\nman - explain how commands work\n" +
			       "\nUSAGE\n\tman <COMMAND>\n" +
			       "\tType 'man cd' to learn about the 'cd' command\n"
			"ls": "\nls - list contents of a dir\n" +
			      "\nUSAGE\n\tls [OPTION] [FILE]\n" +
			      "\tType 'ls' by itself to see the contents of your " +
			      "current working dir.\n" +
			      "\nOPTIONS\n\t-R\n" +
			      "\t\tlist subdirectories recursively\n"
			"cat": "\ncat - show the contents of a file\n" +
			       "\nUSAGE\n\tcat <FILE>\n"
			"head": "\nhead - show the first part of a file\n" +
				"\nUSAGE\n\thead <FILE>\n"
			"tail": "\ntail - show the last part of a file\n" +
				"\nUSAGE\n\ttail <FILE>\n"
			"wc": "\nwc - count the number of lines, words and characters in a file.\n" +
			      "\nUSAGE\n\twc <FILE>\n"
			"grep": "\ngrep - show lines matching a pattern\n" +
				"\nUSAGE\n\tgrep <PATTERN> <FILE>\n"
			"sed": "\nsed - substitute contents of a file\n" +
			       "\nUSAGE\n\tsed 's/PATTERN/REPLACEMENT/' <FILE>\n"
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
