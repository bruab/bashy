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
