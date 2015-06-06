# TaskManager class keeps track of Tasks, updates menu 
class TaskManager
	constructor: () ->
		@winner = false
		@levels = getLevels() # in level.coffee
		@currentLevel = @levels[0]
		@showLevel(@currentLevel)

	# Take a BashyOS object and query it based on the currentTask
	# to see if the task is completed.
	# If so, update currentTask
	# If all tasks are completed (@winner == true), do nothing
	update: (os) ->
		if not @winner
			@currentLevel.update os
			if @currentLevel.isComplete
				@winner = true
				@win()
			else
				@showLevel @currentLevel
		return

	# Take a Task object and display it in the onscreen menu
	showTask: (task) ->
		$("#menu").html("Current task: #{task.name}")
		return

	showLevel: (level) ->
		$("#menuHeader").html("<h3>#{level.name}</h3>")
		@showTask level.tasks[0]

	getHint: () ->
		return @currentLevel.getHint()
	
	# Change the onscreen menu to indicate that all tasks are complete
	win: () ->
		$("#menuHeader").html("")
		$("#menu").html("<h4>You Win!</h4>")
		return

