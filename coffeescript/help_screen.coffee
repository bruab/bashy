class HelpManager
	constructor: () ->
		@seenIntro = false

	onClick: () ->
		if not @seenIntro
			@playIntro()
			@seenIntro = true
		else
			@helpScreen()
		return

	playIntro: () ->
		introHtml = "<h3>Welcome to B@shy!</h3>"
		introHtml += "<p>Use your keyboard to type commands.</p>"
		introHtml += "<p>Available commands are 'pwd' and 'cd'</p>"
		$('#helpText').html(introHtml)
		$('#helpScreen').foundation('reveal', 'open')
		return

	helpScreen: () ->
		helpHtml = "<h3>B@shy Help</h3>"
		helpHtml += "TODO contextual help messages"
		$('#helpText').html(helpHtml)
		$('#helpScreen').foundation('reveal', 'open')
		return

window.HelpManager = HelpManager
