class @BashyOS
class @BashySprite
class @FileSystem
class @DisplayManager

jQuery ->
	# Create canvas and stage, animate
	# TODO create CanvasObject class and all;
	#   this is just so i can say i hit iteration 0.1
	canvas = $("#bashy_canvas")[0]
	stage = new createjs.Stage(canvas)

	bashy_himself = new Image()
	bashy_himself.onload = ->
		startGame()
	bashy_himself.src = "assets/bashy_sprite_sheet.png"

	tick = ->
		stage.update()

	startGame = () ->

		## DRAW FILE SYSTEM MAP ##
		#
		# Write text for available folders
		rootText = new createjs.Text("/", "20px Arial", "black")
		rootText.x = 250
		rootText.y = 120
		rootText.textBaseline = "alphabetic"
		stage.addChild(rootText)

		homeText = new createjs.Text("/home", "20px Arial", "black")
		homeText.x = 140
		homeText.y = 235
		homeText.textBaseline = "alphabetic"
		stage.addChild(homeText)

		mediaText = new createjs.Text("/media", "20px Arial", "black")
		mediaText.x = 340
		mediaText.y = 235
		mediaText.textBaseline = "alphabetic"
		stage.addChild(mediaText)

		# Draw lines from root to children
		line1 = new createjs.Shape()
		line1.graphics.setStrokeStyle(1)
		line1.graphics.beginStroke("gray")
		line1.graphics.moveTo(255, 125)
		line1.graphics.lineTo(350, 220)
		line1.graphics.endStroke()
		stage.addChild(line1)

		line2 = new createjs.Shape()
		line2.graphics.setStrokeStyle(1)
		line2.graphics.beginStroke("gray")
		line2.graphics.moveTo(245, 125)
		line2.graphics.lineTo(150, 220)
		line2.graphics.endStroke()
		stage.addChild(line2)

		## CREATE CHARACTER SPRITE ##
		bashySpriteSheet = new createjs.SpriteSheet({
			# image to use
			images: [bashy_himself],
			# width, height & registration point of each sprite
			frames: {width: 64, height: 64},
			animations: {
			    walking: [0, 4, "walking"],
			    standing: [0, 0, "standing"],
			}
		})

		# create a sprite
		sprite = new createjs.Sprite(bashySpriteSheet, 0)

		# start playing the first sequence:
		sprite.gotoAndPlay "walking"
		sprite.currentFrame = 0
		stage.addChild(sprite)
		bashy_sprite = new BashySprite(sprite)
		
		# we want to do some work before we update the canvas,
		# otherwise we could use Ticker.addListener(stage)
		# (not sure what that means. -bdh)
		createjs.Ticker.addEventListener("tick", tick)
		createjs.Ticker.useRAF = true
		createjs.Ticker.setFPS(5)

		## CREATE A BUNCH OF OBJECTS ##
		os = new BashyOS()
		display_mgr = new DisplayManager(bashy_sprite)
		handleInput = (input) ->
			[cwd, stdout, stderr] = os.handleTerminalInput(input)
			display_mgr.update(cwd)
			# error_mgr.update(stderr)
			# task_mgr.update()
			stdout

		$('#terminal').terminal(handleInput, { greetings: "", prompt: '> ', name: 'test' })

