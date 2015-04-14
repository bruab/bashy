class Directory
	constructor: (@path) ->
		@children = []
	name: () ->
		if @path == "/"
			return @path
		else
			splitPath = @path.split "/"
			len = splitPath.length
			return splitPath[len-1]

	toString: () -> "Directory object with path=#{@path}"

	getChild: (name) ->
		for child in @children
			if child.name() == name
				return child
		return ""

## FileSystem-related functions
createFileSystem = (zoneName) ->
	if zoneName == "nav"
		# TODO create directories and instantiate with them as arg?
		return new FileSystem()
	else
		console.log "createFileSystem called with unknown zone name: " + zoneName
		return None

# FileSystem class stores and answers questions about directories and files
class FileSystem
	constructor: () ->
		@root = new Directory("/")

		media = new Directory("/media")
		pics = new Directory("/media/pics")
		media.children.push(pics)
		@root.children.push(media)

		home = new Directory("/home")
		bashy = new Directory("/home/bashy")
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

	getDirectory: (path) ->
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
getParentPath = (path) ->
	if path == "/"
		return "/"
	else
		splitPath = path.split "/"
		len = splitPath.length
		parentPath = ""
		for i in [0..len-2]
			parentPath = "#{parentPath}/#{splitPath[i]}"
		return cleanPath parentPath

## OS-related functions
createBashyOS = (zoneName) ->
	if zoneName == "nav"
		validCommands = ["cd", "pwd"]
		fileSystem = createFileSystem(zoneName)
		return new BashyOS(validCommands, fileSystem)
	else
		console.log "createBashyOS called with unknown zone name: " + zoneName
		return None

parseRelativePath = (relativePath, cwd) ->
	if relativePath == ".."
		newPath = getParentPath(cwd)
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
			cwd = getParentPath(cwd)
		else
			cwd = cwd + "/" + dir
		fields = fields[1..fields.length]
	return cwd



# OS class in charge of file system, processing user input
class BashyOS
	constructor: (@validCommands, @fileSystem) ->
		# @cwd is a Directory object
		@cwd = @fileSystem.root

	# Function called every time a user types a command
	# Takes input string, returns context, stdout and stderr
	# (for now 'context' = 'cwd')
	runCommand: (command, args) =>
		# No output by default
		[stdout, stderr] = ["", ""]
		if command not in @validCommands
			stderr = "Invalid command: #{command}"
		else if command == 'cd'
			[stdout, stderr] = @cd args
		else if command == 'pwd'
			[stdout, stderr] = @pwd()
		# Return path, stdout, stderr
		return [@cwd.path, stdout, stderr]

	cdRelativePath: (path) =>
		# No output by default
		[stdout, stderr] = ["", ""]
		# Build absolute path
		absolutePath = parseRelativePath(path, @cwd.path)
		absolutePath = cleanPath(absolutePath)
		if @fileSystem.isValidPath(absolutePath)
			@cwd = @fileSystem.getDirectory(absolutePath)
		else
			stderr = "Invalid path: #{absolutePath}"
		return [stdout, stderr]

	cdAbsolutePath: (path) =>
		# No output by default
		[stdout, stderr] = ["", ""]
		absolutePath = cleanPath(path)
		if @fileSystem.isValidPath(path)
			@cwd = @fileSystem.getDirectory(path)
		else
			stderr = "Invalid path"
		return [stdout, stderr]

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

	pwd: () =>
		# Return @cwd as stdout, nothing as stderr
		[stdout, stderr] = ["", ""]
		stdout = @cwd.path
		return [stdout, stderr]
