#!/usr/bin/env coffee
#-*- coding: utf-8 -*-

# Filename: mover.coffee
# Created by 请叫我喵 Alynx.
# alynx.zhou@gmail.com, http://alynx.xyz/

fs = require "fs"
readline = require "readline"
commander = require "commander"

valueSeq = ['C', '#C', 'D', '#D', 'E', 'F', '#F', 'G', '#G', 'A', '#A', 'B']
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
	.description("A mover of number music scores.")
	.usage("[options] <file1 file2 ... files>")
	.option("-m, --move <int>", "Move the key.", parseInt)
	.option("-f, --from [value]", "From which key.")
	.option("-t, --to [value]", "To which key.")
	.parse(process.argv)

if commander.move? and commander.move not in [-12..+12]
	throw new Error("Error: Please use numbers between -12 and +12.")
else if commander.from? or commander.to?
	if not commander.from?
		commander.from = 'C'
	if not commander.to?
		commander.to = 'C'
	commander.from = commander.from.toUpperCase()
	commander.to = commander.to.toUpperCase()
	if not commander.from in valueSeq or not commander.to in valueSeq
		throw new Error("Error: Invalid key.")
	commander.move = valueSeq.indexOf(commander.from) - valueSeq.indexOf(commander.to)

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

printMovedKey = (fixedArr, moveStep) ->
	movedArr = new Array()
	for key in fixedArr
		if keySeq.indexOf(key) isnt -1
			if keySeq.indexOf(key) + moveStep in [0...keySeq.length]
				movedArr.push(keySeq[keySeq.indexOf(key) + moveStep])
			else
				throw new Error("---\nError: Cannot move #{key} with #{moveStep} steps.\n---")
				return
		else
			movedArr.push(key)
	return movedArr

handleFile = (fileStream) ->
	lineNum = 0
	errArrs = []

	rl = readline.createInterface(
		input: fileStream
		output: process.stdout
		terminal: false
	)

	rl.on("line", (line) ->
		lineNum++
		keyArr = keySplit(line)
		console.log(printMovedKey(fixKey(scoreRebuild(keyArr)), commander.move).join(''))
	)

	rl.on('close', () ->
	)

for stream in streamArr
	handleFile(stream)
