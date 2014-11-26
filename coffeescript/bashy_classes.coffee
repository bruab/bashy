class BashyOS
	constructor: (@bashy_sprite) ->

	handleTerminalInput: (input) =>
		@bashy_sprite.moveRight()
		"> " + input + "\n" + input


window.BashyOS = BashyOS
