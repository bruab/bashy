class BashyOS
	constructor: (@bashy_sprite) ->

	handleTerminalInput: (input) =>
		@bashy_sprite.moveRight()
		"> " + input + "\n" + input

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
