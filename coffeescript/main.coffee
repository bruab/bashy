class @BashyOS
class @BashySprite
class @FileSystem

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
		text = new createjs.Text("Hello World", "20px Arial", "black")
		text.x = text.y = 200
		text.textBaseline = "alphabetic"
		stage.addChild(text)


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

		## CREATE OS AND TERMINAL OBJECTS ##
		os = new BashyOS(bashy_sprite)
		$('#terminal').terminal(os.handleTerminalInput, { greetings: "", prompt: '> ', name: 'test' })

