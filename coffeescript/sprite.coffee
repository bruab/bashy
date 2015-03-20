# Functions to create sprite
createBashySprite = (bashy_himself, stage) ->
	## CREATE AND INITIALIZE CHARACTER SPRITE ##
	# Create SpriteSheet first
	bashySpriteSheet = new createjs.SpriteSheet({
		images: [bashy_himself],
		frames: {width: 64, height: 64},
		animations: {
		    walking: [0, 4, "walking"],
		    standing: [0, 0, "standing"],
		}
	})
	# Now create Sprite
	sprite = new createjs.Sprite(bashySpriteSheet, 0)
	sprite.name = "bashy_sprite"
	# Start playing the first sequence:
	sprite.gotoAndPlay "walking"
	sprite.currentFrame = 0
	stage.addChild(sprite)
	bashy_sprite = new BashySprite(sprite)

startTicker = (stage) ->
	# Set up Ticker, frame rate
	tick = -> stage.update()
	createjs.Ticker.addEventListener("tick", tick)
	createjs.Ticker.useRAF = true
	createjs.Ticker.setFPS(5)

# Wrapper for Sprite object, facilitates movement and animation
class BashySprite
	constructor: (@sprite) ->
		# home is 200, 50
		@sprite.x = 200
		@sprite.y = 50

	goToDir: (dir) ->
		# TODO eventually DisplayManager will determine route,
		# simply send destination indices based on map
		if dir == "/"
			@goRoot()
		else if dir == "/home"
			@goHome()
		else if dir == "/media"
			@goMedia()

	## METHODS TO TRAVEL TO SPECIFIC DIRECTORIES ##
	goRoot: ->
		@sprite.x = 200
		@sprite.y = 50

	goHome: ->
		@sprite.x = 80
		@sprite.y = 180

	goMedia: ->
		@sprite.x = 390
		@sprite.y = 180

	# Generic movement method
	moveTo: (x, y) ->
		@sprite.x = x
		@sprite.y = y
			
