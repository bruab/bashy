class BashySprite
	constructor: (@sprite) ->

	moveLeft: ->
		if @sprite.x > 0
			@sprite.x -= 48
		
	moveRight: ->
		limit = 288 - @sprite.getBounds().width
		if @sprite.x < limit
			@sprite.x += 48
		
	moveUp: ->
		if @sprite.y > 0
			@sprite.y -= 48
		
	moveDown: ->
		limit = 288 - @sprite.getBounds().height
		if @sprite.y < limit
			@sprite.y += 48
			
class @BashyOS

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

		bashySpriteSheet = new createjs.SpriteSheet({
			# image to use
			images: [bashy_himself],
			# width, height & registration point of each sprite
			frames: {width: 64, height: 64},
			animations: {
			    walking: [0, 4, "walking"],
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

		# Create darling little OS
		os = new BashyOS(bashy_sprite)

		# Create terminal, hand pass its input to the OS
		$('#terminal').terminal(os.handleTerminalInput, { greetings: "", prompt: '> ', name: 'test' })

