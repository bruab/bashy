class BashyGame
	constructor: ->
		@soundMgr = new SoundManager(playSounds = false)
		# Load spritesheet image; start game when it's loaded
		@bashyImage = new Image()
		@bashyImage.onload = =>
			@initialize()
		@bashyImage.src = "assets/bashy_sprite_sheet.png"

	initialize: ->
		@taskMgr = new TaskManager()
		@os = new BashyOS()

		@displayMgr = createDisplayManager(@bashyImage)
		@displayMgr.drawFileSystem(@os.fileSystem)
		@controller = new BashyController(@os, @taskMgr, @displayMgr, @soundMgr)

		# Create Terminal object
		# 'onBlur: false' guarantees the terminal always stays in focus
		$('#terminal').terminal(@controller.handleInput,
			{ greetings: "", prompt: '$ ', onBlur: false, name: 'bashyTerminal' })
	
