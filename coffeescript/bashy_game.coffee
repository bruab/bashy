class BashyGame
	constructor: ->
		@soundMgr = new SoundManager(playSounds = false)
		@taskMgr = new TaskManager()
		@os = new createBashyOS "nav"
		@displayMgr = new DisplayManager()
		@currentZone = new Zone(@displayMgr, @soundMgr, @taskMgr, @os)
		@currentZone.run()
