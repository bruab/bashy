class BashyOS
	handleTerminalInput: (input) ->
		"> " + input + "\n" + input


jQuery ->
	# TODO create CanvasObject class and all;
	#   this is just so i can say i hit iteration 0.1
	canvas = $("#bashy_canvas")

	# Watch out! canvas is a jQuery object, not a
	#   DOM element. Note [0] in next line:
	context = canvas[0].getContext '2d'

	bashy_himself = new Image()
	# Watch out! Despite all the CamelCase up in here,
	#   note the 'onload' is all lowercase
	bashy_himself.onload = ->
		context.drawImage(bashy_himself, 64, 64)
	bashy_himself.src = "assets/B@shy.64x64.png"

	# Create darling little OS
	os = new BashyOS()
	os.handleTerminalInput('foo')

	# Create terminal, hand pass its input to the OS
	$('#terminal').terminal(os.handleTerminalInput, { prompt: '> ', name: 'test' })

