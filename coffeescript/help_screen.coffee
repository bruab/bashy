class HelpManager
	constructor: () ->
		@seenIntro = false

	onClick: () ->
		if not @seenIntro
			@playIntro()
			@seenIntro = true
		else
			@helpScreen()

	playIntro: () ->
		intro_html = "<h3>Welcome to B@shy!</h3>"
		intro_html += "<p>Use your keyboard to type commands.</p>"
		intro_html += "<p>Available commands are 'pwd' and 'cd'</p>"
		$('#help_text').html(intro_html)
		$('#helpScreen').foundation('reveal', 'open')

	helpScreen: () ->
		help_html = "<h3>B@shy Help</h3>"
		help_html += "TODO contextual help messages"
		$('#help_text').html(help_html)
		$('#helpScreen').foundation('reveal', 'open')

window.HelpManager = HelpManager
