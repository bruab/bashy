parseCommand = (input) ->
	splitInput = input.split /\s+/
	command = splitInput[0]
	args = []
	len = splitInput.length
	if len > 1
		for i in [1..len-1]
			args.push(splitInput[i])
	[command, args]


class BashyController
	constructor: (@os, @task_mgr, @display_mgr, @sound_mgr) ->

	executeCommand: (command, args) ->
		# Get a copy of the current file system
		fs = @os.file_system

		# BashyOS updates and returns context, stdout, stderr
		[cwd, stdout, stderr] = @os.runCommand(command, args)

		# TaskManager checks for completed tasks
		@task_mgr.update(@os)

		# DisplayManager updates map
		# TODO re-implement
		#@display_mgr.update(fs, cwd)
		
		# Handle sound effects
		# TODO can't seem to turn these off.
		###
		if stderr
			@sound_mgr.playOops()
		else
			@sound_mgr.playBoing()
		###

		# Return text to terminal
		if stderr
			stderr
		else
			if stdout
				stdout
			else
				# Returning 'undefined' means no terminal output
				undefined

	# Function called each time user types a command
	# Takes user input string, updates system, returns text to terminal
	handleInput: (input) ->
		# Strip leading and trailing whitespace
		input = input.replace /^\s+|\s+$/g, ""
		# Parse input and check for invalid command
		[command, args] = parseCommand(input)
		if command not in @os.validCommands()
			"Invalid command: " + command
		else
			@executeCommand(command, args)

window.BashyController = BashyController
