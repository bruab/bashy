# Functions to draw map
showRootText = (stage) ->
	rootText = new createjs.Text("/", "20px Arial", "black")
	rootText.x = 250
	rootText.y = 120
	rootText.textBaseline = "alphabetic"
	stage.addChild(rootText)

showHomeText = (stage) ->
	homeText = new createjs.Text("/home", "20px Arial", "black")
	homeText.x = 140
	homeText.y = 235
	homeText.textBaseline = "alphabetic"
	stage.addChild(homeText)

showMediaText = (stage) ->
	mediaText = new createjs.Text("/media", "20px Arial", "black")
	mediaText.x = 340
	mediaText.y = 235
	mediaText.textBaseline = "alphabetic"
	stage.addChild(mediaText)

drawLines = (stage) ->
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

calculateChildCoords = (count, parentX, parentY) ->
	yOffset = 100
	xOffset = 100
	coords = []
	startingX = parentX - 0.5*count*xOffset
	y = parentY + yOffset
	for i in [0..count-1]
		x = startingX + 2*i*xOffset
		coords.push( [x, y] )
	coords

drawFile = (stage, file, x, y) ->
	text = new createjs.Text(file.path, "20px Arial", "black")
	[text.x, text.y] = [x, y]
	text.textBaseline = "alphabetic"
	stage.addChild(text)

drawFileSystem = (stage, fs) ->
	lineOffsetX = 20
	lineOffsetY = 20
	[rootX, rootY] = [250, 120]
	drawFile(stage, fs.root, rootX, rootY)
	numChildren = fs.root.children.length
	childCoords = calculateChildCoords(numChildren, rootX, rootY)
	for i in [0..numChildren-1]
		# Calculate coordinates
		child = fs.root.children[i]
		x = childCoords[i][0]
		y = childCoords[i][1]
		# Draw text
		drawFile(stage, child, x, y)
		# Draw line
		# TODO center line under/above text it points to
		# by calculating length of text, etc. fancy stuff.
		line = new createjs.Shape()
		line.graphics.setStrokeStyle(1)
		line.graphics.beginStroke("gray")
		line.graphics.moveTo(rootX, rootY+lineOffsetY) # TODO should be generic parentX,Y
		line.graphics.lineTo(x+lineOffsetX, y-lineOffsetY)
		line.graphics.endStroke()
		stage.addChild(line)

