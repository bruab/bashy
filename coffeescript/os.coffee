# File class stores contents and path
class File
	constructor: (@name, @contents) ->

# Directory class stores a folder and its files & subdirectories
class Directory
	# Instantiated with a string representing path
	constructor: (@path) ->
		@subdirectories = []
		@files = []

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
		for child in @subdirectories
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
			media.subdirectories.push(pics)
			@root.subdirectories.push(media)

			home = new Directory("/home")
			bashy = new Directory("/home/bashy")
			foo = new File("foo.txt", "This is a simple text file.")
			bashy.files.push(foo)
			home.subdirectories.push(bashy)
			@root.subdirectories.push(home)
		else
			console.log "FileSystem instantiated with unknown zone name: " + zoneName

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

	# Takes a path such as /home/foo/bar.txt and returns the
	# directory ("/home/foo") and the filename ("bar.txt")
	splitPath: (path) ->
		# TODO
		return ["/home/bashy", "foo.txt"]

	# Takes absolute path as a string, returns Directory object
	# Assumes path is valid!
	getDirectory: (path) ->
		if path == "/"
			return @root
		currentParent = @root
		splitPath = path.split "/"
		for dirName in splitPath[1..]
			currentParent = currentParent.getChild(dirName)
		return currentParent

	# Takes absolute path as a string, returns File object
	# Assumes path is valid!
	getFile: (path) ->
		[dirPath, filename] = @splitPath path
		dir = @getDirectory dirPath
		for file in dir.files
			if file.name == filename
				return file

# OS class in charge of file system, executing commands
class BashyOS
	constructor: (zoneName) ->
		if zoneName == "nav"
			@validCommands = ["man", "cd", "pwd", "ls", "cat"]
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
		else if command == 'ls'
			[stdout, stderr] = @ls args[0]
		else if command == 'cat'
			[stdout,stderr] = @cat args[0]
		# Return path, stdout, stderr
		return [@cwd.path, stdout, stderr]

	# Take a list of command line args to 'cd' command;
	# attempt to update @cwd and return stdout, stderr
	cd: (args) =>
		# No output by default
		[stdout, stderr] = ["", ""]
		if args.length == 0
			# The user typed "cd" with no additional args
			@cwd = @fileSystem.getDirectory("/home")
		else
			# The user provided a path
			path = args[0]
			targetDirectory = @getDirectoryFromPath path
			if targetDirectory?
				@cwd = targetDirectory
			else
				stderr = "Invalid path: #{path}"
		return [stdout, stderr]

	# Return @cwd as string to stdout, nothing to stderr
	pwd: () =>
		[stdout, stderr] = ["", ""]
		stdout = @cwd.path
		return [stdout, stderr]

	ls: (path) ->
		[stdout, stderr] = ["", ""]
		if not path?
			# No path provided; use cwd
			dir = @cwd
		else
			dir = @getDirectoryFromPath path
		if not dir?
			stderr = "ls: #{path}: No such file or directory"
		else
			for file in dir.files
				# name is an attribute of File
				stdout += file.name + "\t"
			for directory in dir.subdirectories
				# name is a method on Directory
				stdout += directory.name() + "\t"
		return [stdout, stderr]

	cat: (path) ->
		[stdout, stderr] = ["", ""]
		validFile = false
		file = @getFileFromPath path
		if not file
			# TODO should be stderr?
			stdout = "cat: #{path}: No such file or directory"
		else
			stdout = file.contents
		return [stdout, stderr]

	# Take path as a string, remove extra or trailing slashes
	# e.g. "/home//bashy/pics/" -> "/home/bashy/pics"
	cleanPath: (path) ->
		path = path.replace /\/+/g, "/"
		path = path.replace /\/$/, ""
		return path
		
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

	# Take path as string. If valid path, return Directory object
	# to which it refers. If not valid, return null
	getDirectoryFromPath: (path) ->
		if @isRelativePath path
			path = @parseRelativePath path
			path = @cleanPath path
		if @fileSystem.isValidDirectoryPath path
			return @fileSystem.getDirectory path
		else
			return null

	getFileFromPath: (path) ->
		path = @cleanPath path
		if @isRelativePath path
			path = @parseRelativePath path
			path = @cleanPath path
		if @fileSystem.isValidFilePath path
			return @fileSystem.getFile path
		else
			return null

	isRelativePath: (path) ->
		if path[0] == "/"
			return false
		else
			return true

	# Take relative  path and cwd as strings
	# return absolute path of target directory
	# e.g. parseRelativePath("../foo", "/home/bar") -> "/home/foo"
	parseRelativePath: (relativePath) ->
		cwd = @cwd.path
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
