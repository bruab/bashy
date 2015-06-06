# Wrapper class for JQueryTerm object
class Terminal
	constructor: (inputCallback, tabCallback) ->
		# Create Terminal object
		$('#terminalDiv').terminal(inputCallback,
			{ greetings: "",\
			  prompt: '$ ',\
			  onBlur: false,\ # keeps terminal in focus
			  name: 'bashyTerminal',\
			  height: 300,
			  exceptionHandler: (error) -> console.log error,
			  completion: tabCallback
			})
