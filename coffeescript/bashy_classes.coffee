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
		# TODO
		alert "cd called"
		if args.length == 1
			# TODO
			@cwd = '/home'
		else if args.length > 1
			# TODO relative paths
			@cwd = args[1]

	pwd: () =>
		@cwd

class DisplayManager
	constructor: (@bashy_sprite) ->
	
	update: (new_dir) =>
		# TODO um, actually do stuff?
		# check if new_dir is valid
		# compose and play animation to move to new_dir
		@bashy_sprite.moveRight()

class BashySprite
	constructor: (@sprite) ->

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
			

window.BashyOS = BashyOS
window.BashySprite = BashySprite
window.DisplayManager = DisplayManager
