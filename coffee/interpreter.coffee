#!/usr/bin/env coffee
#-*- coding: utf-8 -*-

# Filename: interpreter.coffee
# Created by 请叫我喵 Alynx.
# alynx.zhou@gmail.com, http://alynx.xyz/

fs = require "fs"
readline = require "readline"
commander = require "commander"

commander
	.version "0.1.0"
	.description "An interpreter of number music scores."
	.usage "[options] <file1 file2 ... files>"
	.option "-d, --debug", "Return an array of score error point."
	.option "-m, --move <int>", "Move the key.", parseInt
	.parse process.argv

# file = commander.file
if commander.args.length
	streamArr = (fs.createReadStream file for file in commander.args)
else
	streamArr = [process.stdin]

if commander.move? and commander.move not in [-12..+12]
	throw new Error "Error: Please use numbers between -12 and +12."

validArr = [' ', '\n', '\t', '|',
	    '(', ')', '{', '}', '[', ']', '<', '>',
	    '0', '1', '2', '3', '4', '5', '6', '7',
	    '#1', '#2', '#3', '#4', '#5', '#6', '#7']
keySeq = ['(1)', '(#1)', '(2)', '(#2)', '(3)', '(4)', '(#4)', '(5)', '(#5)', '(6)', '(#6)', '(7)',
	  '1', '#1', '2', '#2', '3', '4', '#4', '5', '#5', '6', '#6', '7',
	  '[1]', '[#1]', '[2]', '[#2]', '[3]', '[4]', '[#4]', '[5]', '[#5]', '[6]', '[#6]', '[7]',
	  '{1}', '{#1}', '{2}', '{#2}', '{3}', '{4}', '{#4}', '{5}', '{#5}', '{6}', '{#6}', '{7}']

lineNum = 0

keySplit = (line) ->
	keyArr = new Array()
	i = 0
	while i < line.length
		switch line[i]
			when '#'
				if i + 1 < line.length
					keyArr.push '#' + line[i + 1]
				else
					keyArr.push '#'	# If no if-else it will push a #undefined wrongly, and the error columnNum will be wrong.
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
	columnNum = 0
	for key in keyArr
		columnNum += key.length
		if key not in validArr and key[0] isnt ';'
			keyErrArr.push [lineNum, columnNum]
			# throw new Error "Line #{lineNum}, Colomn #{columnNum}: Invalid key \'#{key}\' after automatical key split:\n\n\t#{keyArr.join('')}\n"
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
	# i = 0
	columnNum = 0
	for arr in parenArr
		if arr[0] in ['(', '[', '{']
			testArr = arr[1...arr.length - 1]
			if testArr.length is 0
				columnNum += 2
				parenErrArr.push [lineNum, columnNum]
			else
				j = 0
				while j < testArr.length
					# for paren in ['(', ')', '[', ']', '{', '}']
					if testArr[j] in ['(', ')', '[', ']', '{', '}']
						columnNum += testArr[0..j].join('').length + 1
						parenErrArr.push [lineNum, columnNum]
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
					columnNum += testArr[0..j].join('').length
					parenErrArr.push [lineNum, columnNum]
					# str = ''
					# for x in parenArr
						# str += x.join ''
						# throw new Error "Line #{lineNum}, Colomn #{columnNum}: Unexpected \'#{paren}\' after automatical parentheses completion:\n\n\t#{str}\n"
				j++
		columnNum += arr.join('').length
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
	return rebuildArr

fixKey = (rebuildArr) ->
	fixedArr = new Array()
	for key in rebuildArr
		switch key
			when '(#3)' then fixedArr.push '(4)'
			when '(#7)' then fixedArr.push '1'
			when '#3' then fixedArr.push '4'
			when '#7' then fixedArr.push '[1]'
			when '[#3]' then fixedArr.push '[4]'
			when '[#7]' then fixedArr.push '{1}'
			when '{#3}' then fixedArr.push '{4}'
			else fixedArr.push key
	return fixedArr

printMovedKey = (fixedArr, moveStep) ->
	movedArr = new Array()
	for key in fixedArr
		if keySeq.indexOf(key) isnt -1 and keySeq.indexOf(key) + moveStep in [0...keySeq.length]
			movedArr.push keySeq[keySeq.indexOf(key) + moveStep]
		else
			movedArr.push key
			# console.error "---\nError: Cannot move #{key} with #{moveStep} steps.\n---"
			# return
	console.log movedArr.join ''

handleFile = (fileStream) ->
	lineNum = 0
	errArrs = []

	rl = readline.createInterface
		input: fileStream
		output: process.stdout
		terminal: false

	if commander.debug
		rl.on "line", (line) ->
			lineNum++
			keyArr = keySplit line
			keyErrArr = keyCheck keyArr
			parenArr = parenSplit keyArr
			parenErrArr = parenCheck parenArr
			if keyErrArr.length or parenErrArr.length
				errArrs = errArrs.concat keyErrArr
				errArrs = errArrs.concat parenErrArr
	else
		if commander.move
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
						console.error  "---\nError: Line #{lineNum}, Colomn #{arr[1]}:"
						console.error  "Error: #{line}"
						i = 0
						output =  "Error: "
						while i < arr[1] - 1
							output = output.concat ' '
							i++
						console.error "#{output}^\n---"
				else
					printMovedKey(fixKey(scoreRebuild(keyArr)), commander.move)
		else
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
						console.error  "---\nError: Line #{lineNum}, Colomn #{arr[1]}:"
						console.error  "Error: #{line}"
						i = 0
						output =  "Error: "
						while i < arr[1] - 1
							output = output.concat ' '
							i++
						console.error "#{output}^\n---"
				else
					console.log scoreRebuild(keyArr).join ''

	rl.on 'close', () ->
		if commander.debug
			console.log errArrs
			return errArrs

for stream in streamArr then handleFile stream
