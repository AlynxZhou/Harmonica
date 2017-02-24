#!/usr/bin/env coffee
#-*- coding: utf-8 -*-

# Filename: interpreter.coffee
# Created by 请叫我喵 Alynx.
# alynx.zhou@gmail.com, http://alynx.xyz/

fs = require "fs"
readline = require "readline"

file = process.argv[2]

if file?
	inputStream = fs.createReadStream file
else
	inputStream = process.stdin

rl = readline.createInterface
	input: inputStream
	output: process.stdout
	terminal: false

validArr = [' ', '\n', '\t', '#', '/', '|', '(', ')', '{', '}', '[', ']', '<', '>', '0', '1', '2', '3', '4', '5', '6', '7', '#1', '#2', '#3', '#4', '#5', '#6', '#7']

lineNum = 0
errArrs = new Array()
err = false

keySplit = (line) ->
	keyArr = new Array()
	i = 0
	while i < line.length
		switch line[i]
			when '#'
				keyArr.push '#' + line[i + 1]
				i++
			when ';'
				keyArr.push line[i..line.length]
				i = line.length
			else
				keyArr.push line[i]
		i++
	return keyArr

keyCheck = (keyArr) ->
	keyErrArr = new Array()
	i = 0
	for key in keyArr
		i += key.length
		if key not in validArr and key[0] isnt ';'
			keyErrArr.push [lineNum, i]
			# throw new Error "Line #{lineNum}, Colomn #{i}: Invalid key \'#{key}\' after automatical key split:\n\n\t#{keyArr.join('')}\n"
	return keyErrArr

parenSplit = (keyArr) ->
	parenArr = new Array()
	tempArr = new Array()
	i = 0
	while i < keyArr.length
		switch keyArr[i]
			when ')'
				if parenArr.length
					tempArr.push keyArr[i]
				else
					keyArr.unshift '('
					i = -1
					tempArr = []
			when ']'
				if parenArr.length
					tempArr.push keyArr[i]
				else
					keyArr.unshift '['
					i = -1
					tempArr = []
			when '}'
				if parenArr.length
					tempArr.push keyArr[i]
				else
					keyArr.unshift '{'
					i = -1
					tempArr = []
			when '('
				if tempArr.length
					parenArr.push tempArr
					tempArr = []
				if keyArr[i...keyArr.length].indexOf ')' isnt -1
					parenArr.push keyArr[i..i + keyArr[i...keyArr.length].indexOf ')' ]
					i += keyArr[i...keyArr.length].indexOf ')'
				else if keyArr[keyArr.length - 1] is '\n'
					keyArr[keyArr.length - 1] = ')'
					keyArr.push '\n'
					parenArr.push keyArr[i...keyArr.length - 1]
					i = keyArr.length - 1
				else
					keyArr.push ')'
					parenArr.push keyArr[i...keyArr.length]
					i = keyArr.length
			when '['
				if tempArr.length
					parenArr.push tempArr
					tempArr = []
				if keyArr[i...keyArr.length].indexOf ']' isnt -1
					parenArr.push keyArr[i..i + keyArr[i...keyArr.length].indexOf ']' ]
					i += keyArr[i...keyArr.length].indexOf ']'
				else if keyArr[keyArr.length - 1] is '\n'
					keyArr[keyArr.length - 1] = ']'
					keyArr.push '\n'
					parenArr.push keyArr[i...keyArr.length - 1]
					i = keyArr.length - 1
				else
					keyArr.push ']'
					parenArr.push keyArr[i...keyArr.length]
					i = keyArr.length
			when '{'
				if tempArr.length
					parenArr.push tempArr
					tempArr = []
				if keyArr[i...keyArr.length].indexOf '}' isnt -1
					parenArr.push keyArr[i..i + keyArr[i...keyArr.length].indexOf '}' ]
					i += keyArr[i...keyArr.length].indexOf '}'
				else if keyArr[keyArr.length - 1] is '\n'
					keyArr[keyArr.length - 1] = '}'
					keyArr.push '\n'
					parenArr.push keyArr[i...keyArr.length - 1]
					i = keyArr.length - 1
				else
					keyArr.push '}'
					parenArr.push keyArr[i...keyArr.length]
					i = keyArr.length
			else
				if keyArr[i][0] isnt ';'
					tempArr.push keyArr[i]
		i++
	if tempArr.length then parenArr.push tempArr
	return parenArr

parenCheck = (parenArr) ->
	parenErrArr = new Array()
	i = 0
	colomn = 0
	for arr in parenArr
		if arr[0] in ['(', '[', '{']
			testArr = arr[1...arr.length - 1]
			if testArr.length is 0
				colomn = i + 2
				parenErrArr.push [lineNum, colomn]
			else
				j = 0
				while j < testArr.length
					# for paren in ['(', ')', '[', ']', '{', '}']
					if testArr[j] in ['(', ')', '[', ']', '{', '}']
						colomn = i + testArr[0..j].join('').length + 1
						parenErrArr.push [lineNum, colomn]
						# str = ''
						# for x in parenArr
							# str += x.join ''
							# throw new Error "Line #{lineNum}, Colomn #{i}: Unexpected \'#{paren}\' after automatical parentheses completion:\n\n\t#{str}\n"
					j++
		else
			testArr = arr
			j = 0
			while j < testArr.length
				# for paren in ['(', ')', '[', ']', '{', '}']
				if testArr[j] in ['(', ')', '[', ']', '{', '}']
					colomn = i + testArr[0..j].join('').length
					parenErrArr.push [lineNum, colomn]
					# str = ''
					# for x in parenArr
						# str += x.join ''
						# throw new Error "Line #{lineNum}, Colomn #{i}: Unexpected \'#{paren}\' after automatical parentheses completion:\n\n\t#{str}\n"
				j++
		i += arr.join('').length
	return parenErrArr

scoreRebuild = (keyArr) ->
	rebuildArr = new Array()
	i = 0
	while i < keyArr.length
		switch keyArr[i]
			when '('
				i++
				while keyArr[i] isnt ')'
					if keyArr[i] not in [' ', '\n', '\t']
						rebuildArr.push '(' + keyArr[i] + ')'
					else
						rebuildArr.push keyArr[i]
					i++
			when '['
				i++
				while keyArr[i] isnt ']'
					if keyArr[i] not in [' ', '\n', '\t']
						rebuildArr.push '[' + keyArr[i] + ']'
					else
						rebuildArr.push keyArr[i]
					i++
			when '{'
				i++
				while keyArr[i] isnt '}'
					if keyArr[i] not in [' ', '\n', '\t']
						rebuildArr.push '{' + keyArr[i] + '}'
					else
						rebuildArr.push keyArr[i]
					i++
			else
				rebuildArr.push keyArr[i]
		i++
	return rebuildArr.join ''

rl.on "line", (line) ->
	lineNum++
	keyArr = keySplit line
	keyErrArr = keyCheck keyArr
	parenArr = parenSplit keyArr
	parenErrArr = parenCheck parenArr
	if keyErrArr.length or parenErrArr.length
		errArrs = []
		errArrs = errArrs.concat keyErrArr
		errArrs = errArrs.concat parenErrArr
		for arr in errArrs
			console.log "Error: #{line} at Line #{lineNum}."
			i = 0
			while i < arr[1] + 6
				process.stdout.write ' '
				i++
			console.log "^\n"
		# console.log errArrs
		# console.log "Find KeyError location at #{keyErrArr} and/or ParenError location at #{parenErrArr}."
		# console.log errJson
	# else
		# console.log scoreRebuild keyArr

###
errArrOsort = (errArrs) ->
	swap = new Array()
	i = 0
	while i < errArrs.length
		j = 0
		while j < errArrs.length - 1
			if errArrs[j][0] > errArrs[j + 1][0]
				swap = arr[j].concat()
				arr[j] = errArrs[j + 1].concat()
				arr[j + 1] = swap.concat
			j++
		i++

if err
	errArrOsort errArrs
	lineErrArr = new Array()
	for arr in errArrs then lineErrArr.push arr[0]
	lineNum = 0
	rl.on "line", (line) ->
		lineNum++
		if lineErrArr.indexOf(lineNum) isnt -1
			console.log "Error: #{line}"
			i = 0
			while i < errArrs[lineErrArr.indexOf(lineNum)][1] - 1
				process.stdout.write ' '
			process.stdout.write '^'
###
# This won't work in async.
