# Utility function to determine if path exists in file system
validPath = (path) ->
	if path in ['/', '/home', '/media']
		return true
	else
		return false

# OS class in charge of file system, processing user input
class BashyOS
	# Start user off at root (for now)
	cwd: '/'

	# Nothing to see here
	# TODO instantiate with a FileSystem object
	constructor: () ->

	# Function called every time a user types a command
	# Takes input string, returns context, stdout and stderr
	# (for now 'context' = 'cwd')
	handleTerminalInput: (input) =>
		# No output by default
		[stdout, stderr] = ["", ""]
		# Split up args
		fields = input.split /\s+/
		# Call method according to user command
		# TODO have all methods return stdout and stderr
		# even if they're empty
		if fields[0] == 'cd'
			[stdout, stderr] = @cd fields
		else if fields[0] == 'pwd'
			stdout = @pwd
		# Return context, stdout, stderr
		[@cwd, stdout, stderr]

	cd_relative_path: (path) =>
		[stdout, stderr] = ["", ""]
		# TODO deal with '.'
		newpath = ""
		fields = path.split("/")
		if fields[0] == ".."
			# TODO next bit only works b/c 1-level tree :(
			if fields.length == 1
				@cwd = "/"
			else
				newpath = "/"
				[newpath += x+"/" for x in fields[1..-2]]
				newpath += fields[-1..]
				if validPath(newpath)
					@cwd = newpath
				else
					stderr = "Invalid path"
		else
			# TODO only works b/c 1-level tree :(
			if validPath(@cwd + path)
				@cwd = @cwd + path
			else
				stderr = "Invalid path"
		# Return stdout, stderr
		[stdout, stderr]

	cd: (args) =>
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
				# Absolute path
				if validPath(path)
					@cwd = path
				else
					stderr = "Invalid path"
			else
				[stdout, stderr] = @cd_relative_path(path)
		# Return stdout, stderr
		[stdout, stderr]

	pwd: () =>
		@cwd

class DisplayManager
	constructor: (@bashy_sprite) ->
	
	update: (new_dir) =>
		# TODO check if new_dir is valid
		# TODO compose and play animation to move to new_dir
		@bashy_sprite.goToDir(new_dir)

class BashySprite
	constructor: (@sprite) ->
		# home is 200, 50
		@sprite.x = 200
		@sprite.y = 50

	goToDir: (dir) ->
		if dir == "/"
			@goRoot()
		else if dir == "/home"
			@goHome()
		else if dir == "/media"
			@goMedia()

	goRoot: ->
		@sprite.x = 200
		@sprite.y = 50

	goHome: ->
		@sprite.x = 80
		@sprite.y = 180

	goMedia: ->
		@sprite.x = 390
		@sprite.y = 180

	moveLeft: ->
		if @sprite.x > 0
			@sprite.x -= 48
		
	moveRight: ->
		limit = 288 - @sprite.getBounds().width
		if @sprite.x < limit
			@sprite.x += 48
		
	moveUp: ->
		if @sprite.y > 0
			@sprite.y -= 48
		
	moveDown: ->
		limit = 288 - @sprite.getBounds().height
		if @sprite.y < limit
			@sprite.y += 48

	moveTo: (x, y) ->
		@sprite.x = x
		@sprite.y = y
			

window.BashyOS = BashyOS
window.BashySprite = BashySprite
window.DisplayManager = DisplayManager
