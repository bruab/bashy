# Wrapper class for JQueryTerm object
class Terminal
	constructor: (callback) ->
		# Create Terminal object
		# 'onBlur: false' guarantees the terminal always stays in focus
		$('#terminalDiv').terminal(callback,
			{ greetings: "",\
			  prompt: '$ ',\
			  onBlur: false,\
			  name: 'bashyTerminal',\
			  height: 300,
			  exceptionHandler: (error) -> console.log error
			})
