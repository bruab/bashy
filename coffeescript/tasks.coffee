# Static method to and return Task objects
getLevelOneTasks = ->
	task1Function = (os) ->
		return os.cwd.getPath() == "/home"
	task2Function = (os) ->
		return os.cwd.getPath() == "/"
	task3Function = (os) ->
		return os.cwd.getPath() == "/etc"
	task4Function = (os) ->
		return os.lastCommand() == "cd .."
	task5Function = (os) ->
		return os.cwd.getPath() == "/home/bashy"
	task1 = new Task("navigate to home", ["type 'cd' and press enter"], task1Function)
	task2 = new Task("navigate to root", ["type 'cd /' and press enter"], task2Function)
	task3 = new Task("navigate to /etc", ["type 'cd /etc' and press enter"], task3Function)
	task4 = new Task("type 'cd ..' to go up one dir", ["type 'cd ..' and press enter"], task4Function)
	task5 = new Task("navigate to /home/bashy", ["type 'cd /home/bashy' and press enter"], task5Function)
	return [task1, task2, task3, task4, task5]

getLevelTwoTasks = ->
	task1Function = (os) ->
		return os.lastCommand() == "ls"
	task2Function = (os) ->
		return os.lastCommand() == "ls -R" and os.cwd.getPath() == "/"
	task1 = new Task("use the 'ls' command to see contents of dir", ["type 'ls' and press enter"], task1Function)
	task2 = new Task("navigate back to root '/' and use 'ls -R' to see contents of dir and all the dirs inside it",
		["type 'ls -R' and press enter"], task2Function)
	return [task1, task2]

getLevelThreeTasks = ->
	task1Function = (os) ->
		return os.lastCommand()[0..2] == "cat" and os.lastCommandSucceeded
	task2Function = (os) ->
		return os.lastCommand()[0..2] == "cat" and os.lastCommandSucceeded
	task1 = new Task("use the 'cat' command to see the contents of a file", ["type 'cat /home/bashy/foo.txt' and press enter"], task1Function)
	task2 = new Task("try 'cat' on another file", ["type 'cat /home/bashy/list' and press enter"], task2Function)
	return [task1, task2]

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
			@isComplete = @completeFunction os
			return @isComplete

	toString: () -> @name

