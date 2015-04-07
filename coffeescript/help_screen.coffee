class HelpManager
	constructor: (@taskMgr) ->
		@seenIntro = false

	onClick: () ->
		if not @seenIntro
			@introScreen()
			@seenIntro = true
		else
			@helpScreen()
		return

	introScreen: () ->
		introHtml = "<h3>Welcome to B@shy!</h3>"
		introHtml += "<p>Use your keyboard to type commands.</p>"
		introHtml += "<p>Available commands are 'pwd' and 'cd'</p>"
		$('#helpText').html(introHtml)
		$('#helpScreen').foundation('reveal', 'open')
		return

	helpScreen: () ->
		hint = @taskMgr.currentTask.hints[0]
		helpHtml = "<h3>B@shy Help</h3>"
		helpHtml += "<p>Hint: #{hint}</p>"
		$('#helpText').html(helpHtml)
		$('#helpScreen').foundation('reveal', 'open')
		return
