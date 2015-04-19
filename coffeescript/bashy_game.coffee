class BashyGame
	constructor: ->
		@taskMgr = new TaskManager()
		@os = new createBashyOS "nav"
		@displayMgr = new DisplayManager()
		@currentZone = new Zone(@displayMgr, @taskMgr, @os)
		@currentZone.run()
