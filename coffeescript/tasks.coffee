# TaskManager class keeps track of Tasks, updates Menu (?)
class TaskManager
	constructor: (@menu_mgr, @tasks) ->
		for task in @tasks
			@menu_mgr.showTask(task)

	update: (os) ->
		# Check for newly-completed tasks
		all_complete = true
		for task in @tasks
			if not task.completed
				completed = true
				for command, value of task.tests
					if os[command] != value
						completed = false
				if completed
					task.completed = true
					alert "completed task: " + task.name
				else
					all_complete = false
					alert "uncompleted task: " + task.name
		if all_complete
			alert "you win"

# Task class encapsulates a task name, hint(s) and any number of 
# os queries and the desired responses
class Task
	constructor: (@name, @hints, @tests) ->
		@completed = false

window.TaskManager = TaskManager

