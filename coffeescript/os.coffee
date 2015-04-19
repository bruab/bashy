# Directory class stores a folder and its children
class Directory
	# Instantiated with a string representing path
	constructor: (@path) ->
		@children = []

	# Return the directory's name (not entire path)
	name: () ->
		if @path == "/"
			return @path
		else
			splitPath = @path.split "/"
			len = splitPath.length
			return splitPath[len-1]

	toString: () -> "Directory object with path=#{@path}"

	# Return child Directory object, or empty string if child not found
	getChild: (name) ->
		for child in @children
			if child.name() == name
				return child
		return ""

# FileSystem class stores and answers questions about directories and files
class FileSystem
	constructor: (zoneName) ->
		if zoneName == "nav"
			@root = new Directory("/")

			media = new Directory("/media")
			pics = new Directory("/media/pics")
			media.children.push(pics)
			@root.children.push(media)

			home = new Directory("/home")
			bashy = new Directory("/home/bashy")
			home.children.push(bashy)
			@root.children.push(home)
		else
			console.log "FileSystem instantiated with unknown zone name: " + zoneName

	# Takes absolute path as a string, returns boolean
	isValidPath: (path) ->
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

	# Takes path as a string, returns Directory object
	getDirectory: (path) ->
		if path == "/"
			return @root
		currentParent = @root
		splitPath = path.split "/"
		for dirName in splitPath[1..]
			currentParent = currentParent.getChild(dirName)
		return currentParent

# OS class in charge of file system, executing commands
class BashyOS
	constructor: (zoneName) ->
		if zoneName == "nav"
			@validCommands = ["man", "cd", "pwd"]
			@fileSystem = new FileSystem(zoneName)
		else
			console.log "BashyOS instantiated with unknown zone name: " + zoneName
			@validCommands = []
			@fileSystem = None
		# @cwd is a Directory object
		@cwd = @fileSystem.root
		@man = new Man()

	# Function called every time a user types a valid command
	# Takes command as string, args as list of strings;
	# returns a list of three strings -- path to cwd,
	# stdout and stderr
	runCommand: (command, args) =>
		# No output by default
		[stdout, stderr] = ["", ""]
		if command not in @validCommands
			stderr = "Invalid command: #{command}"
		else if command == 'man'
			[stdout, stderr] = @man.getEntry args[0]
		else if command == 'cd'
			[stdout, stderr] = @cd args
		else if command == 'pwd'
			[stdout, stderr] = @pwd()
		# Return path, stdout, stderr
		return [@cwd.path, stdout, stderr]

	# Take relative path as a string, attempt to update @cwd; 
	# return stdout and stderr
	cdRelativePath: (path) =>
		# No output by default
		[stdout, stderr] = ["", ""]
		# Build absolute path
		absolutePath = @parseRelativePath(path, @cwd.path)
		absolutePath = @cleanPath(absolutePath)
		if @fileSystem.isValidPath(absolutePath)
			@cwd = @fileSystem.getDirectory(absolutePath)
		else
			stderr = "Invalid path: #{absolutePath}"
		return [stdout, stderr]
	
	# Take absolute path as a string, attempt to update @cwd;
	# return stdout and stderr
	cdAbsolutePath: (path) =>
		# No output by default
		[stdout, stderr] = ["", ""]
		absolutePath = @cleanPath(path)
		if @fileSystem.isValidPath(path)
			@cwd = @fileSystem.getDirectory(path)
		else
			stderr = "Invalid path"
		return [stdout, stderr]

	# Take a list of command line args to 'cd' command;
	# attempt to update @cwd and return stdout, stderr
	cd: (args) =>
		# No output by default
		[stdout, stderr] = ["", ""]
		if args.length == 0
			# The user typed "cd" with no additional args
			@cwd = @fileSystem.getDirectory("/home")
		else if args.length > 0
			path = args[0] # not handling options/flags yet
			# Determine if absolute or relative path
			# based on first character
			if path[0] == "/"
				[stdout, stderr] = @cdAbsolutePath(path)
			else
				[stdout, stderr] = @cdRelativePath(path)
		return [stdout, stderr]

	# Return @cwd as string to stdout, nothing to stderr
	pwd: () =>
		[stdout, stderr] = ["", ""]
		stdout = @cwd.path
		return [stdout, stderr]

	# Take path as a string, remove extra or trailing slashes
	# e.g. "/home//bashy/pics/" -> "/home/bashy/pics"
	cleanPath: (path) ->
		splitPath = path.split "/"
		newPath = ""
		for dir in splitPath
			if dir != ""
				newPath = "#{newPath}/#{dir}"
		return newPath
		
	# Take path as a string, return parent path as a string
	getParentPath: (path) ->
		if path == "/"
			return "/"
		else
			splitPath = path.split "/"
			len = splitPath.length
			parentPath = ""
			for i in [0..len-2]
				parentPath = "#{parentPath}/#{splitPath[i]}"
			return @cleanPath parentPath

	# Take relative  path and cwd as strings
	# return absolute path of target directory
	# e.g. parseRelativePath("../foo", "/home/bar") -> "/home/foo"
	parseRelativePath: (relativePath, cwd) ->
		if relativePath == ".."
			newPath = @getParentPath(cwd)
			return newPath
		fields = relativePath.split "/"
		finished = false
		while not finished
			if fields.length == 1
				finished = true
			dir = fields[0]
			if dir == "."
				fields = fields[1..fields.length]
				continue
			else if dir == ".."
				cwd = @getParentPath(cwd)
			else
				cwd = cwd + "/" + dir
			fields = fields[1..fields.length]
		return cwd
