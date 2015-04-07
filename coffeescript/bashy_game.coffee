class BashyGame
	constructor: ->
		###################################################
		################ SOUND ############################
		###################################################
		playSounds = false
		soundMgr = new SoundManager(playSounds)
		# Listen for 'turn off sound' button
		$("#audioOff").click -> soundMgr.soundOff()

		###################################################
		############# MENU AND TASKS ######################
		###################################################
		taskMgr = new TaskManager()

		###################################################
		################ HELP SCREEN ######################
		###################################################
		helpMgr = new HelpManager(taskMgr)
		# Listen for any click whatsoever
		$("#playScreen").click -> helpMgr.onClick()

		###################################################
		############# FILE SYSTEM, OS #####################
		###################################################
		fileSystem = new FileSystem()
		os = new BashyOS(fileSystem)

		###################################################
		################## CANVAS, ETC. ###################
		###################################################
		canvas = $("#bashyCanvas")[0]
		stage = new createjs.Stage(canvas)
		# Load spritesheet image; start game when it's loaded
		bashyImage = new Image()
		bashyImage.src = "assets/bashy_sprite_sheet.png"
		bashyImage.onload = ->
			# Create sprite and display manager
			bashySprite = createBashySprite(bashyImage, stage)
			displayMgr = new DisplayManager(stage, bashySprite)
			displayMgr.drawFileSystem(os.fileSystem)
			startTicker(stage)

			# Create controller
			controller = new BashyController(os, taskMgr, displayMgr, soundMgr)

			# This is here because I can't seem to pass a class method to the terminal
			# as a callback
			handleInput = (input) ->
				controller.handleInput(input)

			# Create Terminal object
			# 'onBlur: false' guarantees the terminal always stays in focus
			$('#terminal').terminal(handleInput,
				{ greetings: "", prompt: '$ ', onBlur: false, name: 'bashyTerminal' })
