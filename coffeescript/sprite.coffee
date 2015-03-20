# Functions to create sprite
createBashySprite = (bashy_himself, stage) ->
	[SPRITEX, SPRITEY] = [200, 50]
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
	sprite.framerate = 4
	sprite.gotoAndPlay "walking"
	sprite.currentFrame = 0
	sprite.x = SPRITEX
	sprite.y = SPRITEY
	stage.addChild(sprite)

startTicker = (stage) ->
	# Set up Ticker, frame rate
	tick = (event) ->
		stage.update(event)
	createjs.Ticker.addEventListener("tick", tick)
	createjs.Ticker.useRAF = true
	createjs.Ticker.setFPS(15)
