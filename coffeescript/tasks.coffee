# TaskManager class keeps track of Tasks, updates menu 
class TaskManager
	constructor: () ->
		@winner = false
		@tasks = @getTasks()
		@currentTask = @tasks[0]
		@showTask(@currentTask)

	# Take a BashyOS object and query it based on the currentTask
	# to see if the task is completed.
	# If so, update currentTask
	# If all tasks are completed (@winner == true), do nothing
	update: (os) ->
		if not @winner
			if @currentTask.done(os)
				if @tasks.length > 1
					@tasks = @tasks[1..]
					@currentTask = @tasks[0]
					@showTask(@currentTask)
				else
					@winner = true
					@win()
		return

	# Take a Task object and display it in the onscreen menu
	showTask: (task) ->
		$("#menu").html(task.name)
		return

	getHint: () ->
		return @currentTask.hints[0]
	
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
			return os.cwd.getPath() == "/media"
		task3Function = (os) ->
			return os.cwd.getPath() == "/"
		task1 = new Task("navigate to home", ["type 'cd' and press enter"], task1Function)
		task2 = new Task("navigate to /media", ["type 'cd /media' and press enter"], task2Function)
		task3 = new Task("navigate to root", ["type 'cd /' and press enter"], task3Function)
		return [task1, task2, task3]

# Task class encapsulates a task name, hint(s) and a manner of
# checking the Task for completion, implemented as any number of
# os queries and their desired responses
class Task
	constructor: (@name, @hints, @completeFunction) ->
		@isComplete = false

	# Take a BashyOS object; return a boolean for whether 
	# this Task is complete
	# Check self for completion using completeFunction
	# if necessary
	done: (os) ->
		if @isComplete
			return true
		else
			@isComplete = @completeFunction(os)
			return @isComplete

	toString: () -> @name
