# Main wrapper class for game; owns Terminal, Display, BashyOS; handles input
class BashyGame
	constructor: ->
		@taskMgr = new TaskManager()
		@os = new BashyOS("nav")
		@displayMgr = new DisplayManager()
		@displayMgr.drawFileSystem(@os.fileSystem)
		@terminal = new Terminal(@handleInput)
		# Listen for help clicks
		$("#helpButton").click => @help()

	# Fetch a hint for the current task, pass it to displayMgr
	help: ->
		currentHint = @taskMgr.currentTask.hints[0]
		@displayMgr.helpScreen currentHint

	# Take raw input, trim whitespace, return command and list of args
	parseCommand: (input) ->
		# Trim leading and trailing whitespace
		input = input.replace /^\s+|\s+$/g, ""
		splitInput = input.split /\s+/
		command = splitInput[0]
		args = splitInput[1..]
		return [command, args]

	# Take command and list of args; have OS perform command, update
	# taskMgr and displayMgr
	executeCommand: (command, args) ->
		# Get a copy of the current file system
		fs = @os.fileSystem
		# @os updates and returns context, stdout, stderr
		# @os.fileSystem may be modified by this command
		[cwd, stdout, stderr] = @os.runCommand(command, args)
		# TaskManager checks for completed tasks
		@taskMgr.update(@os)
		# DisplayManager updates map
		@displayMgr.update(fs, cwd)
		if stderr
			return stderr
		else if stdout
			return stdout
		else
			return
		
	# Function called each time user types a command
	# Take user input string, update system, return text to terminal
	handleInput: (input) =>
		# Strip leading and trailing whitespace
		[command, args] = @parseCommand(input)
		return @executeCommand(command, args)
