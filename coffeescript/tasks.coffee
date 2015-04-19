# TaskManager class keeps track of Tasks, updates Menu (?)
class TaskManager
	constructor: () ->
		@winner = false
		@tasks = @getTasks()
		@currentTask = @tasks[0]
		@showTask(@currentTask)

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

	showTask: (task) ->
		$("#menu").html(task.name)
		return
	
	win: () ->
		$("#menuHeader").html("")
		$("#menu").html("<h4>You Win!</h4>")
		return

	getTasks: () ->
		task1Function = (os) ->
			return os.cwd.path == "/home"
		task2Function = (os) ->
			return os.cwd.path == "/media"
		task3Function = (os) ->
			return os.cwd.path == "/"
		task1 = new Task("navigate to home", ["type 'cd' and press enter"], task1Function)
		task2 = new Task("navigate to /media", ["type 'cd /media' and press enter"], task2Function)
		task3 = new Task("navigate to root", ["type 'cd /' and press enter"], task3Function)
		return [task1, task2, task3]

# Task class encapsulates a task name, hint(s) and any number of 
# os queries and the desired responses
class Task
	constructor: (@name, @hints, @completeFunction) ->
		@isComplete = false

	done: (os) ->
		if @isComplete
			return true
		else
			@isComplete = @completeFunction(os)
			return @isComplete

	toString: () -> @name

# MenuManager updates "current task" menu
class MenuManager
	constructor: () ->

	showTask: (task) ->
		$("#menu").html(task.name)
		return
	
	win: () ->
		$("#menuHeader").html("")
		$("#menu").html("<h4>You Win!</h4>")
		return
