class BashyGame
	constructor: ->
		@taskMgr = new TaskManager()
		@os = new BashyOS("nav")
		@displayMgr = new DisplayManager()
		@currentZone = new Zone(@displayMgr, @taskMgr, @os)
		@currentZone.run()
