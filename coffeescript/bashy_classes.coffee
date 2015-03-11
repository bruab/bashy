# Utility function to determine if path exists in file system
validPath = (path) ->
	if path in ['/', '/home', '/media']
		return true
	else
		return false

# FileSystem class stores and answers questions about directories and files
class FileSystem
	constructor: () ->

	toString: () -> "file system here..."

	isValidPath: (cwd, path) -> true # TODO obviously

###

# FileSystem continued ...
#
# needs children or children()
# needs needs coords
# oh wait no, needs root
# root needs children
# so we're talkin 'File' here, or 'Dir' or whatever.
# let's just say Dirs for now.
# 
# a big question is how to construct -- pass in children and
# parent or add them in? i spose it doesnt matter
###
class File
	constructor: (@name, @coords, @children) ->
	
# OS class in charge of file system, processing user input
class BashyOS
	constructor: (@file_system) ->

	# Start user off at root (for now)
	cwd: '/'

	# Function called every time a user types a command
	# Takes input string, returns context, stdout and stderr
	# (for now 'context' = 'cwd')
	handleTerminalInput: (input) =>
		# No output by default
		[stdout, stderr] = ["", ""]
		# Split up args
		fields = input.split /\s+/
		# Call method according to user command
		# even if they're empty
		if fields[0] == 'cd'
			[stdout, stderr] = @cd fields
		else if fields[0] == 'pwd'
			[stdout, stderr] = @pwd()
		# Return context, stdout, stderr
		[@cwd, stdout, stderr]

	cd_relative_path: (path) =>
		# No output by default
		[stdout, stderr] = ["", ""]
		# TODO deal with '.'
		newpath = ""
		fields = path.split("/")
		if fields[0] == ".."
			# TODO next bit only works b/c 1-level tree :(
			# (should be finding parent directory from @cwd)
			if fields.length == 1
				# Parent is root
				@cwd = "/"
			else
				# Build path starting at root
				newpath = "/"
				[newpath += x+"/" for x in fields[1..-2]]
				# Add last directory separately to avoid trailing slash
				newpath += fields[-1..]
				# Verify and update path (or generate error)
				if validPath(newpath)
					@cwd = newpath
				else
					stderr = "Invalid path"
		else
			# TODO only works b/c 1-level tree :(
			# Target is child of @cwd
			# Verify and update path (or generate error)
			if validPath(@cwd + path)
				@cwd = @cwd + path
			else
				stderr = "Invalid path"
		# Return stdout, stderr
		[stdout, stderr]

	cd_absolute_path: (path) =>
		# No output by default
		[stdout, stderr] = ["", ""]
		if validPath(path)
			@cwd = path
		else
			stderr = "Invalid path"
		# Return stdout, stderr
		[stdout, stderr]

	cd: (args) =>
		# TODO this should call @file_system.isValidPath(@cwd, path)
		# then fail or update @cwd accordingly
		# No output by default
		[stdout, stderr] = ["", ""]
		if args.length == 1
			# The user typed "cd" with no additional args
			@cwd = '/home'
		else if args.length > 1
			path = args[1] # not handling options/flags yet
			# Determine if absolute or relative path
			# based on first character
			if path[0] == "/"
				[stdout, stderr] = @cd_absolute_path(path)
			else
				[stdout, stderr] = @cd_relative_path(path)
		# Return stdout, stderr
		[stdout, stderr]

	pwd: () =>
		# Return @cwd as stdout, nothing as stderr
		[stdout, stderr] = ["", ""]
		stdout = @cwd
		return [stdout, stderr]

# Wrapper for Sprite object, facilitates movement and animation
class BashySprite
	constructor: (@sprite) ->
		# home is 200, 50
		@sprite.x = 200
		@sprite.y = 50

	goToDir: (dir) ->
		# TODO eventually DisplayManager will determine route,
		# simply send destination indices based on map
		if dir == "/"
			@goRoot()
		else if dir == "/home"
			@goHome()
		else if dir == "/media"
			@goMedia()

	## METHODS TO TRAVEL TO SPECIFIC DIRECTORIES ##
	goRoot: ->
		@sprite.x = 200
		@sprite.y = 50

	goHome: ->
		@sprite.x = 80
		@sprite.y = 180

	goMedia: ->
		@sprite.x = 390
		@sprite.y = 180

	# Generic movement method
	moveTo: (x, y) ->
		@sprite.x = x
		@sprite.y = y
			
# Class to handle updating map, character sprite
class DisplayManager
	constructor: (@bashy_sprite) ->
	
	update: (fs, new_dir) =>
		@bashy_sprite.goToDir(new_dir)

# MenuManager updates "current task" menu
class MenuManager
	constructor: () ->

	showTask: (task) ->
		# TODO this seems ghetto, i just want 'append'
		current_html = $("#menu").html()
		$("#menu").html(current_html + "<p>" + task.name + "</p>")


# Attach objects to window so they can be accessed by code in other file
window.BashyOS = BashyOS
window.BashySprite = BashySprite
window.DisplayManager = DisplayManager
window.MenuManager = MenuManager
window.FileSystem = FileSystem
