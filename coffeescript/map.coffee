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

drawFile = (stage, file, x, y) ->
	text = new createjs.Text(file.name(), "20px Arial", "black")
	[text.x, text.y] = [x, y]
	text.textBaseline = "alphabetic"
	stage.addChild(text)

drawChildren = (stage, parent, parentX, parentY) ->
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
			drawChildren(stage, child, childX, childY)
		# Draw text
		drawFile(stage, child, childX, childY)
		# Draw line
		# TODO center line under/above text it points to
		# by calculating length of text, etc. fancy stuff.
		line = new createjs.Shape()
		line.graphics.setStrokeStyle(1)
		line.graphics.beginStroke("gray")
		line.graphics.moveTo(parentX, parentY+lineOffsetY)
		line.graphics.lineTo(childX+lineOffsetX, childY-lineOffsetY)
		line.graphics.endStroke()
		stage.addChild(line)

# Class to handle updating map, character sprite
class DisplayManager
	constructor: (@stage, @bashy_sprite) ->
		[@rootX, @rootY] = [250, 120]
	
	update: (fs, new_dir) =>
		for child in @stage.children[1..] # skip bashy_sprite
			# TODO skip the dern sprite
			# TODO this should be a method to move the map to a certain point
			child.x = child.x + 10
			child.y = child.y - 10

	drawFileSystem: (fs) ->
		drawFile(@stage, fs.root, @rootX, @rootY)
		drawChildren(@stage, fs.root, @rootX, @rootY)
