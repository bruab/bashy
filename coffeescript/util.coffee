class Util
	parseCommand: (input) ->
		splitInput = input.split /\s+/
		command = splitInput[0]
		args = []
		len = splitInput.length
		if len > 1
			for i in [1..len-1]
				args.push(splitInput[i])
		[command, args]

window.Util = Util
