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
		# @history is a list of [command, args] lists
		@history = []
		@lastCommandSucceeded = false

	########################################################################
	######################## BASH FUNCTIONS ################################
	########################################################################
	
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
		stdout = @cwd.getPath()
		return [stdout, stderr]

	# List directory contents
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
			# Is it a file?
			file = @getFileFromPath path
			if file?
				stdout = path
			else
				stderr = "ls: #{path}: No such file or directory"
		else
			for file in dir.files
				# name is an attribute of File
				stdout += file.name + "\t"
			for directory in dir.subdirectories
				# name is a method on Directory
				stdout += directory.name + "\t"
			if recursive
				stdout += "\n\n"
				for directory in dir.subdirectories
					stdout += directory.getPath() + ":\n"
					[newStdout, newStderr] = @ls ["-R", directory.getPath()]
					stdout += newStdout
					stderr += newStderr
		return [stdout, stderr]

	# Return contents of file as stdout
	cat: (args) ->
		[stdout, stderr] = ["", ""]
		if args.length == 0
			stderr = "cat: please provide the path to a file"
			return [stdout, stderr]
		path = args[0]
		file = @getFileFromPath path
		if not file
			stderr = "cat: #{path}: No such file or directory"
		else
			stdout = file.contents
		return [stdout, stderr]

	# Return first 10 lines of a file as stdout
	head: (args) ->
		numberOfLines = 10
		[stdout, stderr] = ["", ""]
		if args.length == 0
			stderr = "head: please provide the path to a file"
			return [stdout, stderr]
		path= args[0]
		file = @getFileFromPath path
		if not file
			stderr = "head: #{path}: No such file or directory"
		else
			splitContents = file.contents.split "\n"
			stdout = splitContents[0..numberOfLines-1].join "\n"
		return [stdout, stderr]

	# Return last 10 lines of a file as stdout
	tail: (args) ->
		numberOfLines = 10
		[stdout, stderr] = ["", ""]
		if args.length == 0
			stderr = "tail: please provide the path to a file"
			return [stdout, stderr]
		path= args[0]
		file = @getFileFromPath path
		if not file
			stderr = "tail: #{path}: No such file or directory"
		else
			splitContents = file.contents.split "\n"
			totalLines = splitContents.length
			stdout = splitContents[totalLines-numberOfLines..].join "\n"
		return [stdout, stderr]

	# Return count of lines, words and chars for a file
	wc: (args) ->
		[stdout, stderr] = ["", ""]
		if args.length == 0
			stderr = "wc: please provide the path to a file"
			return [stdout, stderr]
		path= args[0]
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
		
	# Return lines matching a pattern as stdout
	grep: (args) ->
		[stdout, stderr] = ["", ""]
		if args.length != 2
			stderr = "grep: please provide a pattern and the path to a file"
			return [stdout, stderr]
		pattern = args[0]
		path= args[1]
		file = @getFileFromPath path
		if not file
			stderr = "grep: #{path}: open: No such file or directory"
		else
			lines = file.contents.split "\n"
			matchingLines = (line for line in lines when line.match pattern)
			stdout = matchingLines.join "\n"
		return [stdout, stderr]

	# Return contents of a file with pattern replaced
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

	# Remove a file
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
			[dirPath, filename] = @fileSystem.splitPath path, @cwd
			parentDirectory = @getDirectoryFromPath dirPath
			parentDirectory.removeFile filename
		return [stdout, stderr]

	# Move or rename a file
	mv: (args) ->
		[stdout, stderr] = ["", ""]
		if args.length < 2
			stderr = "mv: please specify a source and a target"
			return [stdout, stderr]
		sourcePath = args[0]
		targetPath = args[1]
		# Is it a file?
		sourceFile = @getFileFromPath sourcePath
		if not sourceFile
			# Is it a directory?
			sourceDirectory = @getDirectoryFromPath sourcePath
			if not sourceDirectory
				stderr = "mv: #{sourcePath}: No such file or directory"
			else
				# remove source from its parent
				sourceDirectory.parent.removeDirectory sourceDirectory.name

				# get target directory, if it already exists
				targetDirectory = @getDirectoryFromPath targetPath
				if not targetDirectory
					# rename
					[parentPath, filename] = @fileSystem.splitPath targetPath, @cwd
					sourceDirectory.name = filename
					parent = @getDirectoryFromPath parentPath
					parent.subdirectories.push sourceDirectory
					return [stdout, stderr]
				if targetPath[targetPath.length-1] == "/"
					# add source as a child of target
					targetDirectory.subdirectories.push(sourceDirectory)
				else
					# replace target with source
					if targetDirectory.name != "/"
						parent = targetDirectory.parent
					else
						parent = targetDirectory
					parent.removeDirectory targetDirectory.name
					parent.subdirectories.push sourceDirectory
					sourceDirectory.parent = parent
				return [stdout, stderr]
		else # It's a file
			# Remove source file
			[sourceDirPath, sourceFilename] = @fileSystem.splitPath sourcePath, @cwd
			sourceDirPath = @cleanPath sourceDirPath
			sourceDirectory = @getDirectoryFromPath sourceDirPath
			sourceDirectory.removeFile sourceFilename
			# Add file to target directory
			[targetDirPath, targetFilename] = @fileSystem.splitPath targetPath, @cwd
			targetDirectory = @getDirectoryFromPath targetDirPath
			targetDirectory.files.push sourceFile
		return [stdout, stderr]

	# Make a copy of a file's contents and place it in a destination directory
	cp: (args) ->
		[stdout, stderr] = ["", ""]
		if args.length < 2
			stderr = "cp: please specify a source and a target"
			return [stdout, stderr]
		sourcePath = args[0]
		sourceFile = @getFileFromPath sourcePath
		if not sourceFile
			stderr = "cp: #{path}: No such file or directory"
		else
			targetPath = args[1]
			targetDir = @getDirectoryFromPath targetPath
			if targetDir?
				# targetPath is a director
				targetFile = new File(sourceFile.name, sourceFile.contents)
				targetDir.files.push targetFile
			else
				# targetPath points to a filename
				[targetDirPath, targetFilename] = @fileSystem.splitPath targetPath, @cwd
				targetFile = new File(targetFilename, sourceFile.contents)
				targetDirectory = @getDirectoryFromPath targetDirPath
				targetDirectory.files.push targetFile
		return [stdout, stderr]


	########################################################################
	###################### UTILITY FUNCTIONS ###############################
	########################################################################

		
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
		cwdPath = @cwd.getPath()
		if relativePath == ".."
			newPath = @getParentPath(cwdPath)
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
				cwdPath = @getParentPath(cwdPath)
			else
				cwdPath = cwdPath + "/" + dir
			fields = fields[1..fields.length]
		return cwdPath

	# Return boolean indicating whether a command is found in history
	# TODO strip strings before comparison
	historyContains: (command) ->
		for item in @history
			if item == command
				return true
		return false

	# Return the last command input
	lastCommand: ->
		return @history[@history.length-1]

	containsCommand: (input) ->
		fields = input.split /\s/
		if fields.length == 1
			return false
		else
			return true # TODO should check if valid command in fields[0]?

	handleTabPath: (input) ->
		# TODO clean up, not handling completion when path is /home or /etc
		splitInput = input.split /\s/
		pathSoFar = splitInput[1]
		# Determine directory pointed to by pathSoFar
		allDirs = pathSoFar.split "/"
		dirs = []
		for dir in allDirs[0..allDirs.length-2]
			if dir?
				dirs.push dir
		if pathSoFar[0] == "/"
			# absolute path
			path = "/"
		else
			path = @cwd.getPath() + "/"
		for dir in dirs
			path += dir + "/"
		path = @cleanPath path
		parentDir = @getDirectoryFromPath path
		lastDirSoFar = allDirs[allDirs.length-1]
		len = lastDirSoFar.length
		# Check parentDir for child directory with name matching text
		for subdir in parentDir.subdirectories
			if subdir.name[0..len-1] == lastDirSoFar
				return subdir.name[len..]
		return ""

	handleTabCommand: (input) ->
		len = input.length
		for command in @validCommands
			if command[0..len-1] == input
				return command[len..]
		return ""

	handleTab: (input) ->
		input = input.replace /^\s+|\s+$/g, "" # trim whitespace
		if @containsCommand input
			result = @handleTabPath input
			return @handleTabPath input
		else
			return @handleTabCommand input

	# Getter so BashyGame object keeps its grubby hands off the OS properties
	getFileSystem: ->
		return @fileSystem

	# Take raw input, trim whitespace, return command and list of args
	parseCommand: (input) ->
		# Trim leading and trailing whitespace
		input = input.replace /^\s+|\s+$/g, ""
		splitInput = input.split /\s+/
		command = splitInput[0]
		args = splitInput[1..]
		return [command, args]

	# Takes command as string, args as list of strings;
	# returns a list of three strings -- path to cwd, stdout, stderr
	runCommand: (input) =>
		@history.push input
		[command, args] = @parseCommand input

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
			[stdout,stderr] = @cat args
		else if command == 'head'
			[stdout, stderr] = @head args
		else if command == 'tail'
			[stdout, stderr] = @tail args
		else if command == 'wc'
			[stdout, stderr] = @wc args
		else if command == 'grep'
			[stdout, stderr] = @grep args
		else if command == 'sed'
			[stdout, stderr] = @sed args
		else if command == 'rm'
			[stdout, stderr] = @rm args
		else if command == 'mv'
			[stdout, stderr] = @mv args
		else if command == 'cp'
			[stdout, stderr] = @cp args
		# Return path, stdout, stderr
		if stderr
			@lastCommandSucceeded = false
		else
			@lastCommandSucceeded = true
		return [@cwd.getPath(), stdout, stderr]
