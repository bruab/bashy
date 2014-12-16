validPath = (path) ->
	if path in ['/', '/home', '/media']
		return true
	else
		return false


class BashyOS
	cwd: '/'

	constructor: () ->

	handleTerminalInput: (input) =>
		[stdout, stderr] = ["", ""]
		fields = input.split /\s+/
		if fields.length >= 1
			if fields[0] == 'cd'
				@cd fields
			else if fields[0] == 'pwd'
				stdout = @pwd
		# returns [cwd, stdout, stderr]
		[@cwd, stdout, stderr]

	cd: (args) =>
		# TODO hecka validation
		if args.length == 1
			@cwd = '/home'
		else if args.length > 1
			path = args[1]
			if path[0] == "/"
				# absolute path
				if validPath(path)
					@cwd = path
			else
				# relative path
				# TODO deal with '..' and '.'
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
					# TODO only works b/c 1-level tree :(
					if validPath(@cwd + path)
						@cwd = @cwd + path

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
