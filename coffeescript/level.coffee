# Static method to and return Level objects
getLevels = ->
	levelOneTasks = getTasks() # in task.coffee
	levelOne = new Level("Level One - Moving Around",\
			"In this level you'll learn how to navigate",
				levelOneTasks)
	return [levelOne]

class Level
	constructor: (@name, @description, @tasks) ->
		@isComplete = false

	update: (os) ->
		if @tasks[0].done(os)
			if @tasks.length > 1
				@tasks = @tasks[1..]
			else
				@isComplete = true

	getHint: ->
		return @tasks[0].hints[0]
