class @BashyOS
class @BashySprite
class @FileSystem
class @DisplayManager
class @TaskManager
class @MenuManager

parseCommand = (input) ->
	splitInput = input.split /\s+/
	command = splitInput[0]
	args = []
	len = splitInput.length
	if len > 1
		for i in [1..len-1]
			args.push(splitInput[i])
	[command, args]


jQuery ->
	###################################################
	################## CANVAS, ETC. ###################
	###################################################
	## EASELJS SETUP CANVAS, STAGE, ANIMATIONS ##
	# Create canvas and stage
	canvas = $("#bashy_canvas")[0]
	stage = new createjs.Stage(canvas)

	# Load spritesheet image; start game when it's loaded
	bashy_himself = new Image()
	bashy_himself.onload = ->
		startGame()
	bashy_himself.src = "assets/bashy_sprite_sheet.png"


	###################################################
	#################### SOUND ########################
	###################################################
	
	## SOUNDJS FUNCTIONS TO LOAD AND PLAY SFX AND THEME ##
	# Be noisy by default
	playSounds = true

	# Function to turn off sound when it gets annoying
	soundOff = () ->
		playSounds = false
		createjs.Sound.stop()

	# Function to play sound effect after each successful user command
	playSound = () ->
		if playSounds
			if Math.random() < 0.5
				createjs.Sound.play("boing1")
			else
				createjs.Sound.play("boing2")

	# Function to play sound effect after erroneous command
	playOops = () ->
		if playSounds
			createjs.Sound.play("oops")

	# Function to play theme song
	playTheme = () ->
		createjs.Sound.play("bashy_theme1", createjs.SoundJS.INTERRUPT_ANY, 0, 0, -1, 0.5)
	# Event listener for loading audio files -- play theme song once it's loaded
	handleFileLoad = (event) =>
		console.log("Preloaded:", event.id, event.src)
		if event.id == "bashy_theme1"
			playTheme()
			soundOff() # delete this line to turn sound back on at start

	# Load sounds and fire handleFileLoad when they're in memory
	createjs.Sound.addEventListener("fileload", handleFileLoad)
	createjs.Sound.alternateExtensions = ["mp3"]
	createjs.Sound.registerManifest(
		    [{id:"boing1", src:"boing1.mp3"},
		     {id:"boing2", src:"boing2.mp3"},
		     {id:"oops", src:"oops.mp3"},
		     {id:"bashy_theme1", src:"bashy_theme1.mp3"}]
			, "assets/")

	# Listen for 'turn off sound' button
	$("#audio_off").click soundOff


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
	########### MAIN GAME SETUP AND LOOP ##############
	###################################################
	startGame = () ->

		# Create OS
		file_system = new FileSystem()
		os = new BashyOS(file_system)

		# Set up graphics
		drawFileSystem(stage, os.file_system)
		# TODO reintroduce sprite
		bashy_sprite = createBashySprite(bashy_himself, stage)
		startTicker(stage)

		# Create other objects
		display_mgr = new DisplayManager(bashy_sprite) # TODO really need this?
		menu_mgr = new MenuManager()
		task_mgr = new TaskManager(menu_mgr)

		# Function called each time user types a command
		# Takes user input string, updates system, returns text to terminal
		handleInput = (input) ->
			# Strip leading and trailing whitespace
			input = input.replace /^\s+|\s+$/g, ""
			# Parse input and check for invalid command
			[command, args] = parseCommand(input)
			if command not in os.validCommands()
				"Invalid command: " + command
			else
				# Get a copy of the current file system
				fs = os.file_system

				# BashyOS updates and returns context, stdout, stderr
				[cwd, stdout, stderr] = os.runCommand(command, args)

				# TaskManager checks for completed tasks
				task_mgr.update(os)

				# DisplayManager updates map
				# TODO re-implement
				#display_mgr.update(fs, cwd)
				
				# Handle sound effects
				if stderr
					playOops()
				else
					playSound()

				# Return text to terminal
				if stderr
					stderr
				else
					if stdout
						stdout
					else
						# Returning 'undefined' means no terminal output
						undefined

		# Create Terminal object
		# 'onBlur: false' guarantees the terminal always stays in focus
		$('#terminal').terminal(handleInput,
			{ greetings: "", prompt: '> ', onBlur: false, name: 'bashy_terminal' })

