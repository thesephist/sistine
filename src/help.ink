` the sistine help command `

std := load('../vendor/std')

log := std.log

HelpMessage := 'Sistine is a static site generator.

Quick start
	1. Place your Markdown content at content/
	2. Add some templates to tpl/
	3. Add your static assets to static/
	4. Add a config.json with your site settings
	5. Run `sistine` to build the site

	More documentation at github.com/thesephist/sistine.

Commands
	build	build the current site
	help	show this help message

Sistine is a project by @thesephist built with Ink.'

main := () => log(HelpMessage)

