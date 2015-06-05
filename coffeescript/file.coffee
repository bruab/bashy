# File class stores contents and path
class File
	constructor: (@name, @contents) ->

# Directory class stores a folder and its files & subdirectories
class Directory
	# Instantiated with a string representing path
	constructor: (@name) ->
		@parent = null
		@subdirectories = []
		@files = []

	getPath: ->
		if @name == "/"
			return "/"
		else
			parent = @parent
			path = @name
			while parent.name != "/"
				path = "#{parent.name}/#{path}"
				parent = parent.parent
			path = "/#{path}"
			return path

	# Return child Directory object, or empty string if child not found
	getChild: (name) ->
		for child in @subdirectories
			if child.name == name
				return child
		return ""

	removeFile: (name) ->
		@files = (f for f in @files when f.name != name)

	removeDirectory: (name) ->
		@subdirectories = (d for d in @subdirectories when d.name != name)

# FileSystem class stores and answers questions about directories and files
class FileSystem
	constructor: () ->
		@root = new Directory("/")

		# TODO lots of repeated code here
		media = new Directory("media")
		media.parent = @root
		@root.subdirectories.push(media)

		pics = new Directory("pics")
		pics.parent = media
		media.subdirectories.push(pics)

		home = new Directory("home")
		home.parent = @root
		@root.subdirectories.push(home)

		bashy = new Directory("bashy")
		bashy.parent = home
		home.subdirectories.push(bashy)

		foo = new File("foo.txt", "This is a simple text file.")
		bashy.files.push(foo)

		list = new File("list", "1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17\n18\n19\n20")
		bashy.files.push(list)

	# Takes absolute path as a string, returns boolean
	isValidDirectoryPath: (path) ->
		if path == "/"
			return true
		splitPath = path.split "/"
		currentParent = @root
		for dirName in splitPath[1..]
			dir = currentParent.getChild dirName
			if not dir
				return false
			else
				currentParent = dir
		return true

	isValidFilePath: (path) ->
		if path == "/"
			return true
		splitPath = path.split "/"
		len = splitPath.length
		currentParent = @root
		# Verify directories
		for dirName in splitPath[1..len-2]
			dir = currentParent.getChild dirName
			if not dir
				return false
			else
				currentParent = dir
		# Verify file itself
		filename = splitPath[len-1]
		for file in currentParent.files
			if file.name == filename
				return true
		return false

	removeLastPart: (path) ->
		# takes something like /home/foo/bar
		# and returns /home/foo
		splitPath = path.split "/"
		return splitPath[0..splitPath.length -2].join "/"

	relativeToAbsolute: (path, cwd) ->
		# DOES NOT VERIFY THAT PATH IS VALID
		dirs = path.split "/"
		path = cwd.getPath()
		for dir in dirs
			if dir == ".."
				path = @removeLastPart path
			else if dir == "."
				continue
			else
				path = "#{path}/#{dir}"
		return path

	# Takes an absolute path such as /home/foo/bar.txt and returns the
	# directory ("/home/foo") and the filename ("bar.txt") paths
	# TODO handle relative path
	splitPath: (path, cwd) ->
		if path[0] != "/"
			# relative path provided; get absolute path
			path = @relativeToAbsolute path, cwd
		splitPath = path.split "/"
		len = splitPath.length
		filename = splitPath[len-1]
		dirPath = splitPath[0..len-2].join "/"
		return [dirPath, filename]

	# Takes absolute path as a string, returns Directory object
	# Assumes path is valid!
	getDirectory: (path, cwd) ->
		if path == "/"
			return @root
		currentParent = @root
		splitPath = path.split "/"
		for dirName in splitPath[1..]
			currentParent = currentParent.getChild(dirName)
		return currentParent

	# Takes absolute path as a string, returns File object
	# Assumes path is valid!
	getFile: (path, cwd) ->
		[dirPath, filename] = @splitPath path, cwd
		dir = @getDirectory dirPath
		for file in dir.files
			if file.name == filename
				return file

