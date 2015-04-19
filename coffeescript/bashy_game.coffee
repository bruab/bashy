class BashyGame
	constructor: ->
		@taskMgr = new TaskManager()
		@os = new BashyOS("nav")
		@displayMgr = new DisplayManager()
		# TODO need to pass in display and task manager or are they just global
		@currentZone = new Zone(@displayMgr, @taskMgr, @os)
		@terminal = new Terminal(@currentZone.handleInput)
		# Listen for help clicks
		$("#helpButton").click => @help()
		@currentZone.run()

	help: ->
		currentHint = @taskMgr.currentTask.hints[0]
		@displayMgr.helpScreen currentHint

