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

	removeFile: (name) ->
		@files = (f for f in @files when f.name != name)

# FileSystem class stores and answers questions about directories and files
class FileSystem
	constructor: () ->
		@root = new Directory("/")

		media = new Directory("/media")
		pics = new Directory("/media/pics")
		media.subdirectories.push(pics)
		@root.subdirectories.push(media)

		home = new Directory("/home")
		bashy = new Directory("/home/bashy")
		foo = new File("foo.txt", "This is a simple text file.")
		list = new File("list", "1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17\n18\n19\n20")
		bashy.files.push(list)
		bashy.files.push(foo)
		home.subdirectories.push(bashy)
		@root.subdirectories.push(home)

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

	# Takes an absolute path such as /home/foo/bar.txt and returns the
	# directory ("/home/foo") and the filename ("bar.txt")
	splitPath: (path) ->
		splitPath = path.split "/"
		len = splitPath.length
		filename = splitPath[len-1]
		dirPath = splitPath[0..len-2].join "/"
		return [dirPath, filename]

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
	constructor: () ->
		@validCommands = ["man", "cd", "pwd", "ls", "cat",
				  "head", "tail", "wc", "grep", "sed",
				  "rm", "mv", "cp"]
		@fileSystem = new FileSystem()
		# @cwd is a Directory object
		@cwd = @fileSystem.root
		@man = new Man()

	# Function called every time a user types a valid command
	# Takes command as string, args as list of strings;
	# returns a list of three strings -- path to cwd,
	# stdout and stderr
	# TODO refactor, hecka duplicated code. can handle by making all commands
	#   take "args" even if they don't need it (?)
	#   Or can have dictionary of commands as strings to methods & args (?)
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
			[stdout, stderr] = @ls args
		else if command == 'cat'
			[stdout,stderr] = @cat args[0]
		else if command == 'head'
			[stdout, stderr] = @head args[0]
		else if command == 'tail'
			[stdout, stderr] = @tail args[0]
		else if command == 'wc'
			[stdout, stderr] = @wc args[0]
		else if command == 'grep'
			[stdout, stderr] = @grep args[0], args[1]
		else if command == 'sed'
			[stdout, stderr] = @sed args
		else if command == 'rm'
			[stdout, stderr] = @rm args
		else if command == 'mv'
			[stdout, stderr] = @mv args
		else if command == 'cp'
			[stdout, stderr] = @cp args
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

	ls: (args) ->
		[stdout, stderr] = ["", ""]
		# TODO function to parse args into flags and path or whatever
		# should be a pretty generic function
		recursive = false
		for arg in args
			if arg == "-R"
				recursive = true
			else
				path = arg
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
			stdout += "\n\n"
			if recursive
				for directory in dir.subdirectories
					stdout += directory.path + ":\n"
					[newStdout, newStderr] = @ls ["-R", directory.path]
					stdout += newStdout
					stderr += newStderr
		return [stdout, stderr]

	cat: (path) ->
		[stdout, stderr] = ["", ""]
		file = @getFileFromPath path
		if not file
			stderr = "cat: #{path}: No such file or directory"
		else
			stdout = file.contents
		return [stdout, stderr]

	head: (path) ->
		numberOfLines = 10
		[stdout, stderr] = ["", ""]
		file = @getFileFromPath path
		if not file
			stderr = "head: #{path}: No such file or directory"
		else
			splitContents = file.contents.split "\n"
			stdout = splitContents[0..numberOfLines-1].join "\n"
		return [stdout, stderr]

	tail: (path) ->
		numberOfLines = 10
		[stdout, stderr] = ["", ""]
		file = @getFileFromPath path
		if not file
			stderr = "tail: #{path}: No such file or directory"
		else
			splitContents = file.contents.split "\n"
			totalLines = splitContents.length
			stdout = splitContents[totalLines-numberOfLines..].join "\n"
		return [stdout, stderr]

	wc: (path) ->
		[stdout, stderr] = ["", ""]
		file = @getFileFromPath path
		if not file
			stderr = "wc: #{path}: open: No such file or directory"
		else
			lines = file.contents.split "\n"
			numberOfLines = lines.length
			words = file.contents.match /\S+/g
			numberOfWords = words.length
			numberOfCharacters = file.contents.length + 1
			stdout = "\t#{numberOfLines}\t#{numberOfWords}\t#{numberOfCharacters}"
		return [stdout, stderr]
		
	grep: (pattern, path) ->
		[stdout, stderr] = ["", ""]
		file = @getFileFromPath path
		if not file
			stderr = "grep: #{path}: open: No such file or directory"
		else
			lines = file.contents.split "\n"
			matchingLines = (line for line in lines when line.match pattern)
			stdout = matchingLines.join "\n"
		return [stdout, stderr]

	sed: (args) ->
		[stdout, stderr] = ["", ""]
		if args.length != 2
			stderr = "sed: invalid or missing arguments."
			return [stdout, stderr]
		file = @getFileFromPath args[1]
		if not file
			stderr = "sed: #{path}: No such file or directory"
		else
			# Parse command
			command = args[0]
			splitCommand = command.split "/"
			if splitCommand[0] != 's'
				stderr = "sed: sorry, command must start with 's'"
				return [stdout, stderr]
			else if splitCommand.length != 4
				stderr = "sed: incomplete command: #{command}"
				return [stdout, stderr]
			pattern = splitCommand[1]
			replacement = splitCommand[2]
			# Process file
			lines = file.contents.split "\n"
			newLines = (line.replace pattern, replacement for line in lines)
			stdout = newLines.join "\n"
		return [stdout, stderr]

	rm: (args) ->
		[stdout, stderr] = ["", ""]
		if args.length < 1
			stderr = "rm: please specify a path"
			return [stdout, stderr]
		path = args[0]
		file = @getFileFromPath path
		if not file
			stderr = "rm: #{path}: No such file or directory"
		else
			[dirPath, filename] = @fileSystem.splitPath path
			parentDirectory = @getDirectoryFromPath dirPath
			parentDirectory.removeFile filename
		return [stdout, stderr]

	mv: (args) ->
		[stdout, stderr] = ["", ""]
		if args.length < 2
			stderr = "mv: please specify a source and a target"
			return [stdout, stderr]
		sourcePath = args[0]
		source = @getFileFromPath sourcePath
		if not source
			stderr = "mv: #{path}: No such file or directory"
		else
			# Remove source file
			[sourceDirPath, sourceFilename] = @fileSystem.splitPath sourcePath
			sourceDirectory = @getDirectoryFromPath sourceDirPath
			sourceDirectory.removeFile sourceFilename
			# Add file to target directory
			targetPath = args[1]
			[targetDirPath, targetFilename] = @fileSystem.splitPath targetPath
			targetDirectory = @getDirectoryFromPath targetDirPath
			targetDirectory.files.push source
		return [stdout, stderr]

	cp: (args) ->
		[stdout, stderr] = ["", ""]
		if args.length < 2
			stderr = "cp: please specify a source and a target"
			return [stdout, stderr]
		sourcePath = args[0]
		source = @getFileFromPath sourcePath
		if not source
			stderr = "cp: #{path}: No such file or directory"
		else
			targetPath = args[1]
			[targetDirPath, targetFilename] = @fileSystem.splitPath targetPath
			targetDirectory = @getDirectoryFromPath targetDirPath
			targetDirectory.files.push source
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
