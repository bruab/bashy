class BashyGame
	constructor: ->
		@soundMgr = new SoundManager(playSounds = false)
		# Load spritesheet image; start game when it's loaded
		@bashyImage = new Image()
		@bashyImage.onload = =>
			@initialize()
		@bashyImage.src = "assets/bashy_sprite_sheet.png"

	initialize: ->
		@displayMgr = createDisplayManager(@bashyImage)
		# Start on level one, navigation
		current_zone = "nav"
		@zoneManager = createZoneManager(@displayMgr, @soundMgr, current_zone)
		@zoneManager.run()
