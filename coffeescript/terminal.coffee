# Wrapper class for JQueryTerm object
class Terminal
	constructor: (callback) ->
		# Create Terminal object
		# 'onBlur: false' guarantees the terminal always stays in focus
		$('#terminal').terminal(callback,
			{ greetings: "", prompt: '$ ', onBlur: false, name: 'bashyTerminal' })
