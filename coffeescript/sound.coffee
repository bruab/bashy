class SoundManager
	constructor: (@playSounds) ->
		createjs.Sound.addEventListener("fileload", @handleFileLoad)
		createjs.Sound.alternateExtensions = ["mp3"]
		createjs.Sound.registerManifest(
			    [{id:"boing1", src:"boing1.mp3"},
			     {id:"boing2", src:"boing2.mp3"},
			     {id:"oops", src:"oops.mp3"},
			     {id:"bashy_theme1", src:"bashy_theme1.mp3"}]
				, "assets/")
		# Listen for 'turn off sound' button
		$("#audioOff").click @soundOff

	soundOff: () ->
		@playSounds = false
		createjs.Sound.stop()
		return

	# Function to play sound effect after each successful user command
	playBoing: () ->
		if @playSounds
			if Math.random() < 0.5
				createjs.Sound.play("boing1")
			else
				createjs.Sound.play("boing2")
		return

	# Function to play sound effect after erroneous command
	playOops: () ->
		if @playSounds
			createjs.Sound.play("oops")
		return

	# Function to play theme song
	playTheme: () ->
		if @playSounds
			createjs.Sound.play("bashy_theme1", createjs.SoundJS.INTERRUPT_ANY, 0, 0, -1, 0.5)
		return

	# Event listener for loading audio files -- play theme song once it's loaded
	handleFileLoad: (event) =>
		console.log("Preloaded:", event.id, event.src)
		if event.id == "bashy_theme1"
			@playTheme()
		return
