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

# Functions to draw map
calculateChildCoords = (count, parentX, parentY) ->
	yOffset = 80
	xOffset = 100
	coords = []
	startingX = parentX - 0.5*count*xOffset
	y = parentY + yOffset
	for i in [0..count-1]
		x = startingX + 2*i*xOffset
		coords.push( [x, y] )
	coords

drawFile = (map, file, x, y) ->
	text = new createjs.Text(file.name(), "20px Arial", "black")
	text.name = file.path
	[text.x, text.y] = [x, y]
	text.textBaseline = "alphabetic"
	map.addChild(text)

drawChildren = (map, parent, parentX, parentY) ->
	lineOffsetX = 20
	lineOffsetY = 20
	numChildren = parent.children.length
	childCoords = calculateChildCoords(numChildren, parentX, parentY)
	for i in [0..numChildren-1]
		# Calculate coordinates
		child = parent.children[i]
		childX = childCoords[i][0]
		childY = childCoords[i][1]
		# Draw children (recursion ftw)
		if child.children.length > 0
			drawChildren(map, child, childX, childY)
		# Draw text
		drawFile(map, child, childX, childY)
		# Draw line
		# TODO center line under/above text it points to
		# by calculating length of text, etc. fancy stuff.
		line = new createjs.Shape()
		line.graphics.setStrokeStyle(1)
		line.graphics.beginStroke("gray")
		line.graphics.moveTo(parentX, parentY+lineOffsetY)
		line.graphics.lineTo(childX+lineOffsetX, childY-lineOffsetY)
		line.graphics.endStroke()
		map.addChild(line)

findFileCoords = (fs, filepath, rootX, rootY) ->
	if filepath == "/"
		return [250, 120] # eew hardcoded, should this be a method?
	else
		# TODO
		return [200, 100]

# Class to handle updating map, character sprite
class DisplayManager
	constructor: (@stage, @bashy_sprite) ->
		#[@rootX, @rootY] = [250, 120]
		[@startingX, @startingY] = [130, 60]
		@centeredOn = "/"
		@map = new createjs.Container()
		@map.name = "map"
		[@map.x, @map.y] = [@startingX, @startingY]
	
	update: (fs, new_dir) =>
		[oldX, oldY] = @getCoordinatesForPath @centeredOn
		[newX, newY] = @getCoordinatesForPath new_dir.path
		[deltaX, deltaY] = [oldX-newX, oldY-newY]
		# TODO tween
		###
		  createjs.Tween.get(circle, { loop: true })
		    .to({ x: 400 }, 1000, createjs.Ease.getPowInOut(4))
		      .to({ alpha: 0, y: 175 }, 500, createjs.Ease.getPowInOut(2))
		        .to({ alpha: 0, y: 225 }, 100)
			  .to({ alpha: 1, y: 200 }, 500, createjs.Ease.getPowInOut(2))
			    .to({ x: 100 }, 800, createjs.Ease.getPowInOut(2));
		###
		createjs.Tween.get(@map).to( {x: @map.x + deltaX, y: @map.y + deltaY}, 500, createjs.Ease.getPowInOut(2))
		###
		@map.x = @map.x + deltaX
		@map.y = @map.y + deltaY
		###
		@centeredOn = new_dir.path

	getCoordinatesForPath: (path) ->
		for item in @map.children
			if item.name == path
				return [item.x, item.y]

	drawFileSystem: (fs) ->
		drawFile(@map, fs.root, @map.x, @map.y)
		drawChildren(@map, fs.root, @map.x, @map.y)
		@stage.addChild(@map)
