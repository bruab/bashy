class @BashyController
class @BashyOS
class @BashySprite
class @FileSystem
class @DisplayManager
class @TaskManager
class @MenuManager
class @SoundManager
class @Util


###################################################
########### MAIN GAME SETUP AND LOOP ##############
###################################################
startGame = (util, sound_mgr, stage, bashy_himself) ->
	# Turn off sound
	sound_mgr.soundOff()

	# Create OS
	file_system = new FileSystem()
	os = new BashyOS(file_system)

	# Set up graphics
	drawFileSystem(stage, os.file_system)
	bashy_sprite = createBashySprite(bashy_himself, stage)
	startTicker(stage)

	# Create other objects
	menu_mgr = new MenuManager()
	task_mgr = new TaskManager(menu_mgr)
	display_mgr = new DisplayManager(bashy_sprite) # TODO really need this?
	controller = new BashyController(os, task_mgr, display_mgr, sound_mgr)

	# Function called each time user types a command
	# Takes user input string, updates system, returns text to terminal
	handleInput = (input) ->
		# Strip leading and trailing whitespace
		input = input.replace /^\s+|\s+$/g, ""
		# Parse input and check for invalid command
		[command, args] = util.parseCommand(input)
		if command not in os.validCommands()
			"Invalid command: " + command
		else
			controller.executeCommand(command, args)

	# Create Terminal object
	# 'onBlur: false' guarantees the terminal always stays in focus
	$('#terminal').terminal(handleInput,
		{ greetings: "", prompt: '> ', onBlur: false, name: 'bashy_terminal' })


jQuery ->
	## LOAD UTILITY FUNCTIONS
	util = new Util() # TODO how to use static library?

	###################################################
	################ SOUND ############################
	###################################################
	sound_mgr = new SoundManager()
	# Listen for 'turn off sound' button
	$("#audio_off").click sound_mgr.soundOff
	# Load sounds and fire sound_mgr.handleFileLoad when they're in memory
	createjs.Sound.addEventListener("fileload", sound_mgr.handleFileLoad)
	createjs.Sound.alternateExtensions = ["mp3"]
	createjs.Sound.registerManifest(
		    [{id:"boing1", src:"boing1.mp3"},
		     {id:"boing2", src:"boing2.mp3"},
		     {id:"oops", src:"oops.mp3"},
		     {id:"bashy_theme1", src:"bashy_theme1.mp3"}]
			, "assets/")

	###################################################
	################ HELP SCREEN ######################
	###################################################
	
	# Play intro on first click; show help screen on subsequent clicks
	seenIntro = false
	$("#playScreen").click ->
		if not seenIntro
			playIntro()
			seenIntro = true
		else
			helpScreen()

	###################################################
	################## CANVAS, ETC. ###################
	###################################################
	## EASELJS SETUP CANVAS, STAGE, ANIMATIONS ##
	# Create canvas and stage
	canvas = $("#bashy_canvas")[0]
	stage = new createjs.Stage(canvas)

	# Load spritesheet image; start game when it's loaded
	bashy_himself = new Image()
	bashy_himself.src = "assets/bashy_sprite_sheet.png"
	bashy_himself.onload = ->
		startGame(util, sound_mgr, stage, bashy_himself)

