class BashyGame
	constructor: ->
		@soundMgr = new SoundManager(playSounds = false)
		@taskMgr = new TaskManager()
		@helpMgr = new HelpManager(@taskMgr)
		# Listen for any click whatsoever
		$("#playScreen").click -> @helpMgr.onClick()
		@os = new BashyOS()

		canvas = $("#bashyCanvas")[0]
		@stage = new createjs.Stage(canvas)
		# Load spritesheet image; start game when it's loaded
		@bashyImage = new Image()
		@bashyImage.onload = =>
			# Create sprite and display manager
			bashySprite = createBashySprite(@bashyImage, @stage)
			@displayMgr = new DisplayManager(@stage, bashySprite)
			@displayMgr.drawFileSystem(@os.fileSystem)
			startTicker(@stage)

			# Create controller
			@controller = new BashyController(@os, @taskMgr, @displayMgr, @soundMgr)

			# This is here because I can't seem to pass a class method to the terminal
			# as a callback
			handleInput = (input) =>
				@controller.handleInput(input)

			# Create Terminal object
			# 'onBlur: false' guarantees the terminal always stays in focus
			$('#terminal').terminal(handleInput,
				{ greetings: "", prompt: '$ ', onBlur: false, name: 'bashyTerminal' })
	
		@bashyImage.src = "assets/bashy_sprite_sheet.png"
