# Main wrapper class for game; owns Terminal, Display, BashyOS; handles input
class BashyGame
	constructor: ->
		@taskMgr = new TaskManager()
		@os = new BashyOS()
		@displayMgr = new DisplayManager(@os.getFileSystem())
		@terminal = new Terminal(@handleInput, @handleTab)
		# Listen for help clicks
		$("#helpButton").click => @help()

	# Fetch a hint for the current task, pass it to displayMgr
	help: ->
		currentHint = @taskMgr.getHint()
		@displayMgr.helpScreen currentHint

	# Take command and list of args; have OS perform command, update
	# taskMgr and displayMgr
	handleInput: (command) =>
		# Get a copy of the current file system
		fs = @os.getFileSystem()
		# @os updates and returns context, stdout, stderr
		# @os.fileSystem may be modified by this command
		[cwd, stdout, stderr] = @os.runCommand command
		# TaskManager checks for completed tasks
		@taskMgr.update @os
		# DisplayManager updates map
		@displayMgr.update fs, cwd
		if stderr
			return stderr
		else if stdout
			return stdout
		else
			return
		
	# Tab completion function
	handleTab: (term, input) =>
		# 'input' is just the last whitespace-separated field,
		# need to get all input
		input = term.get_command()
		term.insert @os.handleTab input
