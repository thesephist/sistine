std := load('../vendor/std')
str := load('../vendor/str')
quicksort := load('../vendor/quicksort')

log := std.log
f := std.format
range := std.range
cat := std.cat
map := std.map
each := std.each
filter := std.filter
reverse := std.reverse
split := str.split
trim := str.trim
sortBy := quicksort.sortBy

Reader := load('../vendor/reader').Reader

iota := (
	S := {i: 0}
	() => (
		i := S.i
		S.i := S.i + 1
		i
	)
)

Directive := {
	Literal: iota()
	Display: iota()
	If: iota()
	Else: iota()
	Each: iota()
	End: iota()
	Part: iota()
}

parseDirective := directive => (
	parts := filter(map(split(directive, ' '), s => trim(s, ' ')), s => len(s) > 0)
	parts.0 :: {
		'if' -> {
			type: Directive.If
			cond: parts.1
		}
		'else' -> {
			type: Directive.Else
		}
		'each' -> {
			type: Directive.Each
			values: parts.1
			by: parts.3
			order: parts.4 :: {
				'desc' -> 'desc'
				_ -> 'asc'
			}
		}
		'end' -> {
			type: Directive.End
		}
		'--' -> {
			type: Directive.Part
			name: parts.1
		}
		_ -> {
			type: Directive.Display
			value: parts.0
		}
	}
)

` transforms a template string into a list of directives `
compile := tpl => compileReader(Reader(tpl))

compileReader := reader => (
	peek := reader.peek
	next := reader.next
	readUntil := reader.readUntil
	readUntilPrefix := reader.readUntilPrefix
	readUntilEnd := reader.readUntilEnd

	parts := ['']
	push := s => (
		parts.len(parts) := s
		parts.len(parts) := ''
	)
	append := s => (
		parts.(len(parts) - 1) := parts.(len(parts) - 1) + s
	)

	(sub := () => c := next() :: {
		() -> map(filter(parts, s => len(s) > 0), part => type(part) :: {
			'string' -> {
				type: Directive.Literal
				value: part
			}
			_ -> part
		})
		'{' -> d := next() :: {
			'{' -> directiveString := readUntilPrefix('}}') :: {
				() -> sub(append(c + d))
				_ -> (
					next(), next() ` swallow following }} `
					directive := parseDirective(directiveString)
					push(directive)
					sub()
				)
			}
			_ -> sub(append(c + d))
		}
		_ -> run := readUntil('{') :: {
			() -> sub(append(c + readUntilEnd()))
			_ -> sub(append(c + run))
		}
	})()
)

` transforms a compiled template (list of directives) into an output string `
generate := (tpl, params) => generateReader(Reader(tpl), params)

generateReader := (reader, params) => (
	peek := reader.peek

	(sub := output => directive := peek() :: {
		() -> output
		` top level else/end directive signals end of current partial template `
		{type: Directive.Else} -> output
		{type: Directive.End} -> output
		_ -> sub(output + generateDirective(reader, params))
	})('')
)

resolveParamValue := (value, params) => (
	keys := split(value, '.')
	(sub := (params, keyIndex) => keyIndex :: {
		len(keys) -> params
		_ -> (
			key := keys.(keyIndex)
			val := params.(key) :: {
				() -> ()
				_ -> sub(val, keyIndex + 1)
			}
		)
	})(params, 0)
)

generateDirective := (reader, params) => (
	next := reader.next
	readUntilEnd := reader.readUntilEnd

	directive := next()
	directive.type :: {
		Directive.Literal -> directive.value
		Directive.Display -> resolved := resolveParamValue(directive.value, params) :: {
			() -> ''
			_ -> string(resolved)
		}
		Directive.If -> (
			ifBranch := generateReader(reader, params)
			elseBranch := (next() :: {
				{type: Directive.Else} -> (
					maybeBranch := generateReader(reader, params)
					next() :: {
						{type: Directive.End} -> maybeBranch
						_ -> (
							log('[sistine] invalid template, could not find {{ end }}')
							''
						)
					}
				)
				{type: Directive.End} -> ''
				() -> (
					log('[sistine] invalid template, could not find {{ else }}')
					''
				)
			})

			resolveParamValue(directive.cond, params) :: {
				0 -> elseBranch
				'' -> elseBranch
				() -> elseBranch
				{} -> elseBranch
				false -> elseBranch
				_ -> ifBranch
			}
		)
		Directive.Each -> values := resolveParamValue(directive.values, params) :: {
			() -> ''
			_ -> (
				values := (values.0 :: {
					() -> map(keys(values), key => values.(key))
					_ -> values
				})
				values := (sortKey := directive.by :: {
					() -> values
					_ -> sortBy(values, item => res := resolveParamValue(sortKey, item) :: {
						() -> ''
						_ -> res
					})
				})
				values := (directive.order :: {
					'asc' -> values
					_ -> reverse(values)
				})

				eachBranch := (
					rest := readUntilEnd()
					restReader := Reader(rest)
					generateReader(restReader, {})
					each(range(0, len((restReader.readUntilEnd)()), 1), reader.back)

					itemParts := map(values, (item, i) => (
						generateReader(Reader(rest), item.i := i)
					))
					cat(itemParts, '')
				)
				elseBranch := (next() :: {
					{type: Directive.Else} -> (
						maybeBranch := generateReader(reader, params)
						next() :: {
							{type: Directive.End} -> maybeBranch
							_ -> (
								log('[sistine] invalid template, could not find {{ end }}')
								''
							)
						}
					)
					{type: Directive.End} -> ''
					() -> (
						log('[sistine] invalid template, could not find {{ else }}')
						''
					)
				})

				len(values) :: {
					0 -> elseBranch
					_ -> eachBranch
				}
			)
		}
		Directive.Part -> partialTpl := params.parts.(directive.name) :: {
			() -> (
				log(f('[sistine] unknown template part "{{ name }}"', directive))
				''
			)
			_ -> generate(partialTpl, params)
		}
		_ -> (
			log(f('[sistine] unknown directive "{{ 0 }}"', [directive]))
			''
		)
	}
)

