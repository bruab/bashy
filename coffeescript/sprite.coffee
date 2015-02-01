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


