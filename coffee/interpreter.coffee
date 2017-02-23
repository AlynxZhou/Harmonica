#!/usr.bin/env coffee
#-*- coding: utf-8 -*-

fs = require "fs"
readline = require "readline"

rl = readline.createInterface
	input: process.stdin
	output: process.stdout
	terminal: false



# scoreEncode = (line) ->

	# for char in line

scoreCheck = (line) ->
	valid_list = [' ', '\n', '#', '(', ')', '{', '}', '[', ']', '<', '>', '0', '1', '2', '3', '4', '5', '6', '7']
	for char in line
		if char not in valid_list
			throw new Error "Invalid music note \'#{char}\'."

rl.on "line", (line) ->
	scoreCheck line
	scoreEncode line

scoreEncode = (line) ->
	# line = input("Music > ")
	line += '\n'
	comp_dict =
		'1': '!'
		'2': '@'
		'3': '#'
		'4': '$'
		'5': '%'
		'6': '^'
		'7': '&'

	i = 0
	while i < line.length
		if line[i] is '#'
			if line[i + 1] of comp_dict
				process.stdout.write comp_dict[line[i + 1]]
				i += 1
			else
				throw new Error "Invalid express \'##{line[i + 1]}\'."
		else
			process.stdout.write line[i]
		i += 1
