class @BashyController
class @BashyOS
class @DisplayManager
class @TaskManager
class @MenuManager
class @HelpManager
class @SoundManager

jQuery ->
	###################################################
	################ SOUND ############################
	###################################################
	playSounds = false
	sound_mgr = new SoundManager(playSounds)
	# Listen for 'turn off sound' button
	$("#audio_off").click -> sound_mgr.soundOff()

	###################################################
	################ HELP SCREEN ######################
	###################################################
	help_mgr = new HelpManager()
	# Listen for any click whatsoever
	$("#playScreen").click -> help_mgr.onClick()

	###################################################
	############# FILE SYSTEM, OS #####################
	###################################################
	file_system = new FileSystem()
	os = new BashyOS(file_system)

	###################################################
	############# MENU AND TASKS ######################
	###################################################
	task_mgr = new TaskManager()

	###################################################
	################## CANVAS, ETC. ###################
	###################################################
	canvas = $("#bashy_canvas")[0]
	stage = new createjs.Stage(canvas)
	# Load spritesheet image; start game when it's loaded
	bashy_image = new Image()
	bashy_image.src = "assets/bashy_sprite_sheet.png"
	bashy_image.onload = ->
		# Create sprite and display manager
		bashy_sprite = createBashySprite(bashy_image, stage)
		display_mgr = new DisplayManager(stage, bashy_sprite)
		display_mgr.drawFileSystem(os.file_system)
		startTicker(stage)

		# Create controller
		controller = new BashyController(os, task_mgr, display_mgr, sound_mgr)

		# This is here because I can't seem to pass a class method to the terminal
		# as a callback
		handleInput = (input) ->
			controller.handleInput(input)

		# Create Terminal object
		# 'onBlur: false' guarantees the terminal always stays in focus
		$('#terminal').terminal(handleInput,
			{ greetings: "", prompt: '> ', onBlur: false, name: 'bashy_terminal' })
