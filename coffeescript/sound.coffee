class SoundManager
	constructor: () ->
		@playSounds = true

	soundOff: () ->
		@playSounds = false
		createjs.Sound.stop()

	# Function to play sound effect after each successful user command
	playBoing: () ->
		if @playSounds == true
			if Math.random() < 0.5
				createjs.Sound.play("boing1")
			else
				createjs.Sound.play("boing2")

	# Function to play sound effect after erroneous command
	playOops: () ->
		if @playSounds == true
			createjs.Sound.play("oops")

	# Function to play theme song
	playTheme: () ->
		createjs.Sound.play("bashy_theme1", createjs.SoundJS.INTERRUPT_ANY, 0, 0, -1, 0.5)

	# Event listener for loading audio files -- play theme song once it's loaded
	handleFileLoad: (event) =>
		console.log("Preloaded:", event.id, event.src)
		if event.id == "bashy_theme1"
			@playTheme()
			#@soundOff() # delete this line to turn sound back on at start

window.SoundManager = SoundManager
