get_tasks = () ->
	task1_fn = (os) ->
		return os.cwd.path == "/home"
	task2_fn = (os) ->
		return os.cwd.path == "/media"
	task3_fn = (os) ->
		return os.cwd.path == "/"
	task1 = new Task("navigate to home", ["type 'cd' and press enter"], task1_fn)
	task2 = new Task("navigate to /media", ["type 'cd /media' and press enter"], task2_fn)
	task3 = new Task("navigate to root", ["type 'cd /' and press enter"], task3_fn)
	return [task1, task2, task3]

# TaskManager class keeps track of Tasks, updates Menu (?)
class TaskManager
	constructor: (@menu_mgr) ->
		@winner = false
		@tasks = get_tasks()
		@current_task = @tasks[0]
		@menu_mgr.showTask(@current_task)

	update: (os) ->
		if not @winner
			if @current_task.done(os)
				if @tasks.length > 1
					@tasks = @tasks[1..]
					@current_task = @tasks[0]
					@menu_mgr.showTask(@current_task)
				else
					@winner = true
					@menu_mgr.win()

# Task class encapsulates a task name, hint(s) and any number of 
# os queries and the desired responses
class Task
	constructor: (@name, @hints, @complete_fn) ->
		@is_complete = false

	done: (os) ->
		if @is_complete
			return true
		else
			@is_complete = @complete_fn(os)
			return @is_complete

	toString: () ->
		@name

# MenuManager updates "current task" menu
class MenuManager
	constructor: () ->

	showTask: (task) ->
		$("#menu").html(task.name)
	
	win: () ->
		$("#menu_header").html("")
		$("#menu").html("<h4>You Win!</h4>")


window.TaskManager = TaskManager
window.MenuManager = MenuManager
