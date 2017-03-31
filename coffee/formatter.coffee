#!/usr/bin/env coffee
#-*- coding: utf-8 -*-

# Filename: interpreter.coffee
# Created by 请叫我喵 Alynx.
# alynx.zhou@gmail.com, http://alynx.xyz/

fs = require "fs"
readline = require "readline"
commander = require "commander"

validArr = [' ', '\n', '\t', '|',
	    '(', ')', '{', '}', '[', ']', '<', '>',
	    '0', '1', '2', '3', '4', '5', '6', '7',
	    '#1', '#2', '#3', '#4', '#5', '#6', '#7']
keySeq = ['(1)', '(#1)', '(2)', '(#2)', '(3)', '(4)', '(#4)', '(5)', '(#5)', '(6)', '(#6)', '(7)',
	  '1', '#1', '2', '#2', '3', '4', '#4', '5', '#5', '6', '#6', '7',
	  '[1]', '[#1]', '[2]', '[#2]', '[3]', '[4]', '[#4]', '[5]', '[#5]', '[6]', '[#6]', '[7]',
	  '{1}', '{#1}', '{2}', '{#2}', '{3}', '{4}', '{#4}', '{5}', '{#5}', '{6}', '{#6}', '{7}']

commander
	.version("0.1.0")
	.description("An interpreter of number music scores.")
	.usage("[options] <file1 file2 ... files>")
	.option("-d, --debug", "Return an array of score error point.")
	.parse(process.argv)

if commander.args.length
	streamArr = (fs.createReadStream(file) for file in commander.args)
else
	streamArr = [process.stdin]

keySplit = (line) ->
	keyArr = new Array()
	i = 0
	while i < line.length
		switch line[i]
			when '#'
				if i + 1 < line.length
					keyArr.push('#' + line[i + 1])
				else
					keyArr.push('#')	# If no if-else it will push a #undefined wrongly, and the error columnNum will be wrong.
				i++
			when ';'
				keyArr.push(line[i..line.length])
				i = line.length
			else
				keyArr.push(line[i])
		i++
	return keyArr

keyCheck = (lineNum, keyArr) ->
	keyErrArr = new Array()
	columnNum = 0
	for key in keyArr
		columnNum += key.length
		if key not in validArr and key[0] isnt ';'
			keyErrArr.push([lineNum, columnNum])
	return keyErrArr

parenSplit = (keyArr) ->
	parenArr = new Array()
	tempArr = new Array()
	i = 0
	while i < keyArr.length
		switch keyArr[i]
			when ')'
				if parenArr.length
					tempArr.push(keyArr[i])
				else
					keyArr.unshift('(')
					i = -1
					tempArr = []
			when ']'
				if parenArr.length
					tempArr.push(keyArr[i])
				else
					keyArr.unshift('[')
					i = -1
					tempArr = []
			when '}'
				if parenArr.length
					tempArr.push(keyArr[i])
				else
					keyArr.unshift('{')
					i = -1
					tempArr = []
			when '('
				if tempArr.length
					parenArr.push(tempArr)
					tempArr = []
				if keyArr[i...keyArr.length].indexOf(')') isnt -1
					parenArr.push(keyArr[i..i + keyArr[i...keyArr.length].indexOf(')')])
					i += keyArr[i...keyArr.length].indexOf(')')
				else if keyArr[keyArr.length - 1] is '\n'
					keyArr[keyArr.length - 1] = ')'
					keyArr.push('\n')
					parenArr.push(keyArr[i...keyArr.length - 1])
					i = keyArr.length - 1
				else
					keyArr.push(')')
					parenArr.push(keyArr[i...keyArr.length])
					i = keyArr.length
			when '['
				if tempArr.length
					parenArr.push(tempArr)
					tempArr = []
				if keyArr[i...keyArr.length].indexOf(']') isnt -1
					parenArr.push(keyArr[i..i + keyArr[i...keyArr.length].indexOf(']')])
					i += keyArr[i...keyArr.length].indexOf(']')
				else if keyArr[keyArr.length - 1] is '\n'
					keyArr[keyArr.length - 1] = ']'
					keyArr.push('\n')
					parenArr.push(keyArr[i...keyArr.length - 1])
					i = keyArr.length - 1
				else
					keyArr.push(']')
					parenArr.push(keyArr[i...keyArr.length])
					i = keyArr.length
			when '{'
				if tempArr.length
					parenArr.push(tempArr)
					tempArr = []
				if keyArr[i...keyArr.length].indexOf('}') isnt -1
					parenArr.push(keyArr[i..i + keyArr[i...keyArr.length].indexOf(')}')])
					i += keyArr[i...keyArr.length].indexOf('}')
				else if keyArr[keyArr.length - 1] is '\n'
					keyArr[keyArr.length - 1] = '}'
					keyArr.push('\n')
					parenArr.push(keyArr[i...keyArr.length - 1])
					i = keyArr.length - 1
				else
					keyArr.push('}')
					parenArr.push(keyArr[i...keyArr.length])
					i = keyArr.length
			else
				if keyArr[i][0] isnt ';'
					tempArr.push(keyArr[i])
		i++
	if tempArr.length
		parenArr.push(tempArr)
	return parenArr

parenCheck = (lineNum, parenArr) ->
	parenErrArr = new Array()
	columnNum = 0
	for arr in parenArr
		if arr[0] in ['(', '[', '{']
			testArr = arr[1...arr.length - 1]
			if testArr.length is 0
				columnNum += 2
				parenErrArr.push([lineNum, columnNum])
			else
				j = 0
				while j < testArr.length
					if testArr[j] in ['(', ')', '[', ']', '{', '}']
						columnNum += testArr[0..j].join('').length + 1
						parenErrArr.push([lineNum, columnNum])
					j++
		else
			testArr = arr
			j = 0
			while j < testArr.length
				if testArr[j] in ['(', ')', '[', ']', '{', '}']
					columnNum += testArr[0..j].join('').length
					parenErrArr.push([lineNum, columnNum])
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
						rebuildArr.push('(' + keyArr[i] + ')')
					else
						rebuildArr.push(keyArr[i])
					i++
			when '['
				i++
				while keyArr[i] isnt ']'
					if keyArr[i] not in [' ', '\n', '\t']
						rebuildArr.push('[' + keyArr[i] + ']')
					else
						rebuildArr.push(keyArr[i])
					i++
			when '{'
				i++
				while keyArr[i] isnt '}'
					if keyArr[i] not in [' ', '\n', '\t']
						rebuildArr.push('{' + keyArr[i] + '}')
					else
						rebuildArr.push(keyArr[i])
					i++
			else
				rebuildArr.push(keyArr[i])
		i++
	return rebuildArr

fixKey = (rebuildArr) ->
	fixedArr = new Array()
	for key in rebuildArr
		switch key
			when '(#3)' then fixedArr.push('(4)')
			when '(#7)' then fixedArr.push('1')
			when '#3' then fixedArr.push('4')
			when '#7' then fixedArr.push('[1]')
			when '[#3]' then fixedArr.push('[4]')
			when '[#7]' then fixedArr.push('{1}')
			when '{#3}' then fixedArr.push('{4}')
			else fixedArr.push(key)
	return fixedArr

handleFile = (fileStream) ->
	lineNum = 0
	errArrs = []

	rl = readline.createInterface(
		input: fileStream
		output: process.stdout
		terminal: false
	)

	if commander.debug
		rl.on("line", (line) ->
			lineNum++
			keyArr = keySplit(line)
			keyErrArr = keyCheck(lineNum, keyArr)
			parenArr = parenSplit(keyArr)
			parenErrArr = parenCheck(lineNum, parenArr)
			if keyErrArr.length or parenErrArr.length
				errArrs = errArrs.concat(keyErrArr)
				errArrs = errArrs.concat(parenErrArr)
		)
	else
		rl.on("line", (line) ->
			lineNum++
			keyArr = keySplit(line)
			keyErrArr = keyCheck(lineNum, keyArr)
			parenArr = parenSplit(keyArr)
			parenErrArr = parenCheck(lineNum, parenArr)
			if keyErrArr.length or parenErrArr.length
				errArrs = []
				errArrs = errArrs.concat(keyErrArr)
				errArrs = errArrs.concat(parenErrArr)
				for arr in errArrs
					console.error("---\nError: Line #{arr[0]}, Colomn #{arr[1]}:")
					console.error("Error: #{line}")
					i = 0
					output = "Error: "
					while i < arr[1] - 1
						output += ' '
						i++
					console.error("#{output}^\n---")
			else
				console.log(fixKey(scoreRebuild(keyArr)).join(''))
		)

	rl.on('close', () ->
		if commander.debug
			console.log(errArrs)
			return errArrs
	)

for stream in streamArr
	handleFile(stream)
