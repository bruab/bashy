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

window.BashyController = BashyController
