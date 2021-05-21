` the sistine build command `

std := load('../vendor/std')
str := load('../vendor/str')
json := load('../vendor/json')

log := std.log
f := std.format
clone := std.clone
slice := std.slice
cat := std.cat
map := std.map
each := std.each
filter := std.filter
readFile := std.readFile
writeFile := std.writeFile
index := str.index
split := str.split
hasSuffix? := str.hasSuffix?
trimPrefix := str.trimPrefix
trimSuffix := str.trimSuffix
trim := str.trim
deJSON := json.de

Reader := load('../vendor/reader').Reader

tpl := load('tpl')
compile := tpl.compile
generate := tpl.generate

md := load('../vendor/md')
compileMarkdown := md.transform

Newline := char(10)

ContentDir := './content'
PublicDir := './public'
TplDir := './tpl'

err := msg => log(f('[sistine] {{0}}', [msg]))

copyFile := (src, dest) => readFile(src, file => file :: {
	() -> err(f('could not copy file "{{0}}"', [src]))
	_ -> writeFile(dest, file, res => res :: {
		true -> ()
		_ -> err(f('could not copy file to "{{0}}"', [dest]))
	})
})

copyDir := (src, dest) => make(dest, evt => evt.type :: {
	'error' -> err(f('could not copy dir "{{0}}"', [src]))
	_ -> dir(src, evt => evt.type :: {
		'error' -> err(evt.message)
		_ -> (
			dirs := map(filter(evt.data, ent => ent.dir), ent => ent.name)
			files := map(filter(evt.data, ent => ~(ent.dir)), ent => ent.name)

			each(files, fileName => copyFile(
				src + '/' + fileName
				dest + '/' + fileName
			))

			each(dirs, dirName => copyDir(
				src + '/' + dirName
				dest + '/' + dirName
			))
		)
	})
})

` copy static/ into public/ `
copyDir('./static', './public')

` compile Markdown, taking into account front matter `
compileContentPage := file => (
	reader := Reader(split(file, Newline))
	next := reader.next
	readUntil := reader.readUntil

	` fallback content if cannot parse front matter `
	default := () => {
		words: len(split(file, ' '))
		content: compileMarkdown(file)
	}

	(sub := () => next() :: {
		'---' -> frontMatter := readUntil('---') :: {
			() -> default()
			_ -> (
				next() ` swallow --- `

				pageParams := {}
				each(frontMatter, fmLine => (
					colonIdx := index(fmLine, ':')
					key := trim(slice(fmLine, 0, colonIdx), ' ')
					value := trim(slice(fmLine, colonIdx + 1, len(fmLine)), ' ')
					pageParams.(key) := value
				))

				pageParams.words := len(split(file, ' '))
				pageParams.content := compileMarkdown(cat((reader.readUntilEnd)(), Newline))
			)
		}
		_ -> default()
	})()
)

withParts := cb => dir(TplDir + '/parts', evt => evt.type :: {
	'error' -> cb({})
	_ -> (
		files := evt.data
		compiled := {}
		each(files, entry => readFile(TplDir + '/parts/' + entry.name, file => (
			file :: {
				() -> compiled.trimSuffix(entry.name, '.html') := []
				_ -> compiled.trimSuffix(entry.name, '.html') := compile(file)
			}
			len(keys(compiled)) :: {
				len(files) -> cb(compiled)
			}
		)))
	)
})

` transforms contnet file path into canonical content file path `
toContentPath := contentFilePath => trimPrefix(contentFilePath, ContentDir)

` transforms content file path to public html file path `
toPublicPath := contentFilePath => (
	filePath := slice(contentFilePath, len(ContentDir), len(contentFilePath))
	hasSuffix?(filePath, '.md') :: {
		false -> err(f('"{{ 0 }}" is not an .md file', [filePath]))
		_ -> hasSuffix?(filePath, '/index.md') :: {
			true -> trimSuffix(filePath, '/index.md') + '/index.html'
			_ -> trimSuffix(filePath, '.md') + '/index.html'
		}
	}
)

withCompiledContent := cb => (
	Pages := []

	Jobs := {
		dispatched: 0
		done: 0
	}
	dispatchJob := job => (
		Jobs.dispatched := Jobs.dispatched + 1
		job(() => (
			Jobs.done := Jobs.done + 1
			Jobs.done :: {
				Jobs.dispatched -> cb(Pages)
			}
		))
	)

	processFile := (filePath, rootPages, cb) => dispatchJob(done => readFile(filePath, file => (
		file :: {
			() -> err(f('could not read content file "{{ 0 }}"', [file]))
			_ -> (
				publicPath := toPublicPath(filePath)
				contentPath := toContentPath(filePath)
				page := compileContentPage(file)

				page.path := trimSuffix(publicPath, 'index.html')
				page.publicPath := publicPath
				page.contentPath := contentPath
				page.index? := hasSuffix?(contentPath, '/index.md')
				page.pages := {}
				page.roots := rootPages

				Pages.len(Pages) := page
				cb(page)
			)
		}
		done()
	)))

	processDir := (dirPath, rootPages, cb) => dispatchJob(
		done => dir(dirPath, evt => evt.type :: {
			'error' -> (
				err(f('could not read content dir "{{ 0 }}"', [dirPath]))
				done()
			)
			_ -> (
				files := filter(evt.data, ent => ~(ent.dir | ent.name.0 = '.'))

				indexFile := filter(files, fileEnt => fileEnt.name = 'index.md').0
				pageFiles := filter(files, fileEnt => ~(fileEnt.name = 'index.md'))

				indexFile :: {
					() -> ()
					_ -> processFile(dirPath + '/index.md', rootPages, indexPage => (
						rootPages := clone(rootPages)
						rootPages.len(rootPages) := indexPage

						each(pageFiles, fileEnt => processFile(
							dirPath + '/' + fileEnt.name
							rootPages
							page => indexPage.pages.trimSuffix(fileEnt.name, '.md') := page
						))

						dirs := filter(evt.data, ent => ent.dir)
						each(dirs, dirEnt => processDir(
							dirPath + '/' + dirEnt.name
							rootPages
							page => indexPage.pages.(dirEnt.name) := page
						))

						cb(indexPage)
					))
				}
				done()
			)
		})
	)

	processDir(ContentDir, [], page => ())
)

ensureFileDirExistsThen := (fileName, cb) => (
	pathNames := split(fileName, '/')
	dirNames := slice(pathNames, 0, len(pathNames) - 1) :: {
		[] -> cb()
		_ -> make(cat(dirNames, '/'), evt => evt.type :: {
			'error' -> err(f('could not create output dir "{{ 0 }}"', [cat(dirNames, '/')]))
			_ -> cb()
		})
	}
)

writePageToPublic := (path, file) => (
	publicPath := PublicDir + '/' + path
	ensureFileDirExistsThen(publicPath, () => (
		writeFile(publicPath, file, res => res :: {
			() -> err(f('could not write output file "{{ 0 }}"', [publicPath]))
			_ -> ()
		})
	))
)

resolveTemplatePath := (contentPath, cb) => (
	pathParts := split(contentPath, '/')
	searchQueue := filter([
		trimSuffix(contentPath, '.md') + '.html'
		hasSuffix?(contentPath, '/index.md') & ~(contentPath = '/index.md') :: {
			false -> ()
			_ -> (
				trimSuffix(contentPath, '/index.md') + '.html'
			)
		}
		cat(slice(pathParts, 0, len(pathParts) - 1), '/') + '/index.html'
		'/index.html'
	], it => ~(it = ()))

	(sub := i => i :: {
		len(searchQueue) -> cb(())
		_ -> stat(TplDir + searchQueue.(i), evt => evt.type :: {
			'error' -> (
				err(f('could not stat "{{ 0 }}"', [searchQueue.(i)]))
				cb(())
			)
			_ -> evt.data :: {
				() -> sub(i + 1)
				_ -> cb(searchQueue.(i))
			}
		})
	})(0)
)

withSiteParams := siteParams => withParts(parts => (
	siteParams.parts := parts

	withCompiledContent(pages => (
		` generate feeds `
		rssTpl := TplDir + '/rss.xml'
		readFile(rssTpl, file => file :: {
			() -> err(f('could not read rss template "{{ 0 }}"', [rssTpl]))
			_ -> (
				log('[sistine] rss --( /rss.xml )-> /index.xml')
				params := (clone(siteParams).pages := pages)
				generated := generate(compile(file), params)
				writePageToPublic('/index.xml', generated)
			)
		})

		` generate content pages `
		each(pages, page => (
			params := (clone(siteParams).page := page)

			resolveTemplatePath(page.contentPath, templatePath => templatePath :: {
				() -> err(f('could not resolve template for "{{ contentPath }}"', page))
				_ -> readFile(TplDir + templatePath, file => file :: {
					() -> err(f('could not read "{{ 0 }}"', [TplDir + templatePath]))
					_ -> (
						log(f('[sistine] {{ 0 }} --( {{ 1 }} )-> {{ 2 }}'
							[page.contentPath, templatePath, page.path]))
						generated := generate(compile(file), params)
						writePageToPublic(page.publicPath, generated)
					)
				})
			})
		))
	))
))

main := () => readFile('./config.json', file => file :: {
	() -> log('[sistine] could not read configuration file')
	_ -> withSiteParams({
		site: deJSON(file)
	})
})

