class BashyGame
	constructor: ->
		@soundMgr = new SoundManager(playSounds = false)
		@taskMgr = new TaskManager()
		@os = createBashyOS "nav"
		# Load spritesheet image; start game when it's loaded
		@bashyImage = new Image()
		@bashyImage.onload = =>
			@initialize()
		@bashyImage.src = "assets/bashy_sprite_sheet.png"

	initialize: ->
		@displayMgr = createDisplayManager(@bashyImage)
		@currentZone = new Zone(@displayMgr, @soundMgr, @taskMgr, @os)
		@currentZone.run()
