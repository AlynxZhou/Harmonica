#!/usr.bin/env coffee
#-*- coding: utf-8 -*-

fs = require "fs"
readline = require "readline"

file = process.argv[2]

rl = readline.createInterface
	#input: fs.createReadStream(file)
	input: process.stdin
	output: process.stdout
	terminal: false

lineNum = 0

scoreCheck = (line) ->
	validArr = [' ', '\n', '\t', '#', '(', ')', '{', '}', '[', ']', '<', '>', '0', '1', '2', '3', '4', '5', '6', '7']
	for char in line
		if char not in validArr
			throw new Error "Invalid music note \'#{char}\'."

scoreEncode = (line) ->
	noteArr = new Array()
	i = 0
	while i < line.length
		switch line[i] #is '#'
			when '#'
				if line[i + 1] in ['0', '1', '2', '3', '4', '5', '6', '7']
					noteArr.push '#' + line[i + 1]
					# process.stdout.write comp_dict[line[i + 1]]
					i++
				else
					throw new Error "Invalid express \'##{line[i + 1]}\' at Line #{lineNum}, Column #{i + 1}: \n\n\t#{line}\n"
			when ';'
				noteArr.push line[i..line.length]
				i = line.length
			else
				noteArr.push line[i]
				# process.stdout.write line[i]
		i++
	return noteArr

parenAdd = (arr) ->
	parenArr = new Array()
	i = 0
	while i < arr.length
		switch arr[i]
			when '('
				i++
				while arr[i] isnt ')'
					if arr[i] not in [' ', '\n', '\t']
						parenArr.push '(' + arr[i] + ')'
					else
						parenArr.push arr[i]
					i++
			when '['
				i++
				while arr[i] isnt ']'
					if arr[i] not in [' ', '\n', '\t']
						parenArr.push '[' + arr[i] + ']'
					else
						parenArr.push arr[i]
					i++
			when '{'
				i++
				while arr[i] isnt '}'
					if arr[i] not in [' ', '\n', '\t']
						parenArr.push '{' + arr[i] + '}'
					else
						parenArr.push arr[i]
					i++
			else
				parenArr.push arr[i]
		i++
	return parenArr

rl.on "line", (line) ->
	lineNum++
	# scoreCheck line
	console.log (parenAdd scoreEncode line).join('')