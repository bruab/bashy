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
		@zoneManager = createZoneManager(@displayMgr, @soundMgr, "nav")
