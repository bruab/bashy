class File
	constructor: (@path) ->
		@children = []
	name: () ->
		if @path == "/"
			return @path
		else
			splitPath = @path.split "/"
			len = splitPath.length
			return splitPath[len-1]

	toString: () -> "File object with path=#{@path}"

	getChild: (name) ->
		for child in @children
			if child.name() == name
				return child
		return ""

# FileSystem class stores and answers questions about directories and files
class FileSystem
	constructor: () ->
		@root = new File("/")

		media = new File("/media")
		pics = new File("/media/pics")
		media.children.push(pics)
		@root.children.push(media)

		home = new File("/home")
		bashy = new File("/home/bashy")
		home.children.push(bashy)
		@root.children.push(home)

	isValidPath: (path) ->
		# Takes absolute path, returns boolean
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

	getFile: (path) ->
		if path == "/"
			return @root
		currentParent = @root
		splitPath = path.split "/"
		for dirName in splitPath[1..]
			currentParent = currentParent.getChild(dirName)
		return currentParent

cleanPath = (path) ->
	splitPath = path.split "/"
	newPath = ""
	for dir in splitPath
		if dir != ""
			newPath = "#{newPath}/#{dir}"
	return newPath
	
# helper function for path parsing
getParentPath = (dir) ->
	if dir.path == "/"
		return "/"
	else
		splitPath = dir.path.split "/"
		len = splitPath.length
		parentPath = ""
		for i in [0..len-2]
			parentPath = "#{parentPath}/#{splitPath[i]}"
		return parentPath

# OS class in charge of file system, processing user input
class BashyOS
	constructor: (@fileSystem) ->
		@cwd = @fileSystem.root

	# This feels ghetto but works for now
	validCommands: () ->
		return ["cd", "pwd"]

	# Function called every time a user types a command
	# Takes input string, returns context, stdout and stderr
	# (for now 'context' = 'cwd')
	runCommand: (command, args) =>
		# No output by default
		[stdout, stderr] = ["", ""]
		if command == 'cd'
			[stdout, stderr] = @cd args
		else if command == 'pwd'
			[stdout, stderr] = @pwd()
		# Return context, stdout, stderr
		return [@cwd, stdout, stderr]

	cdRelativePath: (path) =>
		# TODO hecka code duplication going on here
		# No output by default
		[stdout, stderr] = ["", ""]
		newpath = ""
		fields = path.split("/")
		if fields[0] == ".."
			# Build absolute path
			absolutePath = getParentPath(@cwd)
			for field in [fields[1..]]
				if absolutePath == "/"
					absolutePath = absolutePath + field
				else
					absolutePath = "#{absolutePath}/#{field}"
			absolutePath = cleanPath(absolutePath)
			if @fileSystem.isValidPath(absolutePath)
				@cwd = @fileSystem.getFile(absolutePath)
			else
				stderr = "Invalid path: #{absolutePath}"
		else if fields[0] == "."
			# Build absolute path
			if @cwd == @fileSystem.root
				absolutePath = "/#{path[2..]}"
			else
				absolutePath = "#{@cwd}/#{path[2..]}"
			absolutePath = cleanPath(absolutePath)
			if @fileSystem.isValidPath(absolutePath)
				@cwd = @fileSystem.getFile(absolutePath)
			else
				stderr = "Invalid path: #{absolutePath}"
			
		else
			# Build absolute path
			if @cwd == @fileSystem.root
				absolutePath = @cwd.path + path
			else
				absolutePath = "#{@cwd.path}/#{path}"
			absolutePath = cleanPath(absolutePath)
			if @fileSystem.isValidPath(absolutePath)
				@cwd = @fileSystem.getFile(absolutePath)
			else
				stderr = "Invalid path: #{absolutePath}"
		return [stdout, stderr]

	cdAbsolutePath: (path) =>
		# No output by default
		[stdout, stderr] = ["", ""]
		absolutePath = cleanPath(path)
		if @fileSystem.isValidPath(path)
			@cwd = @fileSystem.getFile(path)
		else
			stderr = "Invalid path"
		return [stdout, stderr]

	cd: (args) =>
		# No output by default
		[stdout, stderr] = ["", ""]
		if args.length == 0
			# The user typed "cd" with no additional args
			@cwd = @fileSystem.getFile("/home")
		else if args.length > 0
			path = args[0] # not handling options/flags yet
			# Determine if absolute or relative path
			# based on first character
			if path[0] == "/"
				[stdout, stderr] = @cdAbsolutePath(path)
			else
				[stdout, stderr] = @cdRelativePath(path)
		return [stdout, stderr]

	pwd: () =>
		# Return @cwd as stdout, nothing as stderr
		[stdout, stderr] = ["", ""]
		stdout = @cwd.path
		return [stdout, stderr]


# Attach objects to window so they can be accessed by code in other file
window.BashyOS = BashyOS
