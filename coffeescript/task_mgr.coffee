# TaskManager class keeps track of Tasks, updates menu 
class TaskManager
	constructor: () ->
		@winner = false
		@levels = @getLevels()
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

	# Create and return Task objects
	getTasks: () ->
		task1Function = (os) ->
			return os.cwd.getPath() == "/home"
		task2Function = (os) ->
			return os.cwd.getPath() == "/"
		task3Function = (os) ->
			return os.cwd.getPath() == "/media"
		task4Function = (os) ->
			return os.lastCommand() == "cd .."
		task1 = new Task("navigate to home", ["type 'cd' and press enter"], task1Function)
		task2 = new Task("navigate to root", ["type 'cd /' and press enter"], task2Function)
		task3 = new Task("navigate to /media", ["type 'cd /media' and press enter"], task3Function)
		task4 = new Task("type 'cd ..' to go up one dir", ["type 'cd ..' and press enter"], task4Function)
		return [task1, task2, task3, task4]

	# Create and return Level objects
	getLevels: () ->
		levelOneTasks = @getTasks()
		levelOne = new Level("Level One - Moving Around",\
				"In this level you'll learn how to navigate",
					levelOneTasks)
		return [levelOne]


