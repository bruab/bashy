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
	coords = []
	startingX = parentX - 100
	y = parentY + 100
	for i in [0..count-1]
		x = startingX + i*100
		# TODO this should obviously depend on the #children
		coords.push( [x, y] )
	coords

drawFile = (stage, file, x, y) ->
	text = new createjs.Text(file.path, "20px Arial", "black")
	[text.x, text.y] = [x, y]
	text.textBaseline = "alphabetic"
	stage.addChild(text)

drawFileSystem = (stage, fs) ->
	[rootX, rootY] = [250, 120]
	drawFile(stage, fs.root, rootX, rootY)
	numChildren = fs.root.children.length
	childCoords = calculateChildCoords(numChildren, rootX, rootY)
	for i in [0..numChildren-1]
		child = fs.root.children[i]
		x = childCoords[i][0]
		y = childCoords[i][1]
		drawFile(stage, child, x, y)

###

drawLine = (stage, startCoords, endCoords) ->
	line = new createjs.Shape()
	line.graphics.setStrokeStyle(1)
	line.graphics.beginStroke("gray")
	line.graphics.moveTo(startCoords.x, startCoords.y)
	line.graphics.lineTo(endCoords.x, endCoords.y)
	line.graphics.endStroke()
	stage.addChild(line)

drawDirName = (stage, name, coords) ->
	text = new createjs.Text(name, "20px Arial", "black")
	text.x = coords.x
	text.y = coords.y
	text.textBaseline = "alphabetic"
	stage.addChild(text)

drawRoot = (stage) ->
	drawDirName("/", (0,0) )

drawDir = (stage, dir, parentCoords) ->
	# do stuff with stage and line and whatever the hell
	# like, say
	drawDirName(stage, dir.name, dir.coords)
	drawLine(stage, coords, parentCoords)
	
drawChildren = (stage, dir) ->
	for child in dir.children
		# do something indexy in this loop to be able
		# to calculate child's coords based on own coords
		child.coords = doSomething()
		if not child.children
			drawDir(stage, child, dir.coords) # pass in child's parents coords
		else
			drawChildren(stage, child)

drawFileSystemMap = (stage, fs) ->
	drawRoot()
	for dir in fs.root.children
		drawChildren(dir)
		
###
