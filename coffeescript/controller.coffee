parseCommand = (input) ->
	splitInput = input.split /\s+/
	command = splitInput[0]
	args = splitInput[1..]
	return [command, args]


class BashyController
	constructor: (@os, @taskMgr, @displayMgr, @soundMgr) ->

	executeCommand: (command, args) ->
		# Get a copy of the current file system
		fs = @os.fileSystem

		# BashyOS updates and returns context, stdout, stderr
		[cwd, stdout, stderr] = @os.runCommand(command, args)

		# TaskManager checks for completed tasks
		@taskMgr.update(@os)

		# DisplayManager updates map
		@displayMgr.update(fs, cwd)
		
		# Handle sound effects
		if stderr
			@soundMgr.playOops()
		else
			@soundMgr.playBoing()

		# Return text to terminal
		if stderr
			return stderr
		else
			if stdout
				return stdout
			else
				# Returning 'undefined' means no terminal output
				return undefined

	# Function called each time user types a command
	# Takes user input string, updates system, returns text to terminal
	handleInput: (input) ->
		# Strip leading and trailing whitespace
		input = input.replace /^\s+|\s+$/g, ""
		# Parse input and check for invalid command
		[command, args] = parseCommand(input)
		if command not in @os.validCommands()
			return "Invalid command: #{command}"
		else
			return @executeCommand(command, args)

window.BashyController = BashyController
