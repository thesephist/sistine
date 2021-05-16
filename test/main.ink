`` runMarkdownTests := load('md').run
`` runReaderTests := load('reader').run

s := (load('../vendor/suite').suite)(
	'Sistine test suite'
)

`` runMarkdownTests(s.mark, s.test)
`` runReaderTests(s.mark, s.test)

(s.end)()

