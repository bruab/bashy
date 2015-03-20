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
		[@rootX, @rootY] = [250, 120]
		@map = new createjs.Container()
	
	update: (fs, new_dir) =>
		[newX, newY] = findFileCoords(fs, new_dir.path, @rootX, @rootY)
		deltaX = @rootX - newX
		deltaY = @rootY - newY
		# TODO i guess i'm storing these values twice so it's
		# necessary to sync them; not sure if i care
		[@rootX, @rootY] = [@rootX+deltaX, @rootY+deltaY]
		for child in @stage.children[1..] # skip bashy_sprite
			child.x = child.x + deltaX
			child.y = child.y + deltaY

	drawFileSystem: (fs) ->
		drawFile(@map, fs.root, @rootX, @rootY)
		drawChildren(@map, fs.root, @rootX, @rootY)
		@stage.addChild(@map)
