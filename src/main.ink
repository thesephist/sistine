#!/usr/bin/env ink

std := load('../vendor/std')
json := load('../vendor/json')
cli := load('../vendor/cli')

` sistine commands `
build := load('build').main
help := load('help').main

given := (cli.parsed)()
given.verb :: {
	'build' -> build()
	'help' -> help()
	_ -> build()
}

