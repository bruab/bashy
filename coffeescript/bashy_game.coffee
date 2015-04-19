class BashyGame
	constructor: ->
		@taskMgr = new TaskManager()
		@os = new BashyOS("nav")
		@displayMgr = new DisplayManager()
		@displayMgr.drawFileSystem(@os.fileSystem)
		@terminal = new Terminal(@handleInput)
		# Listen for help clicks
		$("#helpButton").click => @help()

	help: ->
		currentHint = @taskMgr.currentTask.hints[0]
		@displayMgr.helpScreen currentHint

	parseCommand: (input) ->
		# Trim leading and trailing whitespace
		input = input.replace /^\s+|\s+$/g, ""
		splitInput = input.split /\s+/
		command = splitInput[0]
		args = splitInput[1..]
		# Return list with command (string) and args (list of strings)
		return [command, args]

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
		
	# Function called each time user types a command
	# Takes user input string, updates system, returns text to terminal
	handleInput: (input) =>
		# Strip leading and trailing whitespace
		[command, args] = @parseCommand(input)
		return @executeCommand(command, args)
