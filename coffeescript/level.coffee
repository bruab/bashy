# Static method to and return Level objects
getLevels = ->
	levelOneTasks = getLevelOneTasks() # in task.coffee
	levelOne = new Level(
		"Level One - Moving Around",\
		"In this level you'll learn how to navigate",
		levelOneTasks)
	levelTwoTasks = getLevelTwoTasks()
	levelTwo = new Level(
		"Level Two - Exploring Dirs",
		"In this level you'll learn to look inside dirs",
		levelTwoTasks)
	levelThreeTasks = getLevelThreeTasks()
	levelThree = new Level(
		"Level Three - Exploring Files",
		"Now it's time to see what's in a file",
		levelThreeTasks)
	levelFourTasks = getLevelFourTasks()
	levelFour = new Level(
		"Level Four - Filtering Files",
		"Get only the parts of a file that you want",
		levelFourTasks)
	return [levelOne, levelTwo, levelThree, levelFour]

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
