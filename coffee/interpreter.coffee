#!/usr/bin/env coffee
#-*- coding: utf-8 -*-

# Filename: interpreter.coffee
# Created by 请叫我喵 Alynx.
# alynx.zhou@gmail.com, http://alynx.xyz/

fs = require "fs"
readline = require "readline"

file = process.argv[2]

if file?
	inputStream = fs.createReadStream(file)
else
	inputStream = process.stdin

rl = readline.createInterface
	input: inputStream
	output: process.stdout
	terminal: false

validArr = [' ', '\n', '\t', '#', '(', ')', '{', '}', '[', ']', '<', '>', '0', '1', '2', '3', '4', '5', '6', '7', '#1', '#2', '#3', '#4', '#5', '#6', '#7']

lineNum = 0

keySplit = (line) ->
	keyArr = new Array()
	i = 0
	while i < line.length
		switch line[i]
			when '#'
				keyArr.push '#' + line[i + 1]
				i++
					# throw new Error "Invalid express \'##{line[i + 1]}\' at Line #{lineNum}, Column #{i + 1}: \n\n\t#{line}\n"
			when ';'
				keyArr.push line[i..line.length]
				i = line.length
			else
				keyArr.push line[i]
		i++
	return keyArr

keyCheck = (keyArr) ->
	i = 0
	for key in keyArr
		i += key.length
		if key not in validArr and key[0] isnt ';'
			throw new Error "Invalid key \'#{key}\' at Line #{lineNum}, Colomn #{i}:\n\n\t#{keyArr.join('')}\n"
	return keyArr

parenSplit = (keyArr) ->
	parenArr = new Array()
	tempArr = new Array()
	i = 0
	while i < keyArr.length
		switch keyArr[i]
			when ')'
				keyArr.unshift '('
				i = -1
				tempArr = []
			when ']'
				keyArr.unshift '['
				i = -1
				tempArr = []
			when '}'
				keyArr.unshift '{'
				i = -1
				tempArr = []
			when '('
				if tempArr.length
					parenArr.push(tempArr)
					tempArr = []
				if keyArr[i...keyArr.length].indexOf(')') isnt -1
					parenArr.push(keyArr[i..keyArr.indexOf(')')])
					i += keyArr[i...keyArr.length].indexOf(')')
				else
					keyArr.push(')')
					parenArr.push(keyArr[i..keyArr.length])
					i = keyArr.length
			when '['
				if tempArr.length
					parenArr.push(tempArr)
					tempArr = []
				if keyArr[i...keyArr.length].indexOf(']') isnt -1
					parenArr.push(keyArr[i..keyArr.indexOf(']')])
					i += keyArr[i...keyArr.length].indexOf(']')
				else
					keyArr.push(']')
					parenArr.push(keyArr[i..keyArr.length])
					i = keyArr.length
			when '{'
				if tempArr.length
					parenArr.push(tempArr)
					tempArr = []
				if keyArr[i...keyArr.length].indexOf('}') isnt -1
					parenArr.push(keyArr[i..keyArr.indexOf('}')])
					i += keyArr[i...keyArr.length].indexOf('}')
				else
					keyArr.push('}')
					parenArr.push(keyArr[i..keyArr.length])
					i = keyArr.length
			else
				if keyArr[i][0] isnt ';'
					tempArr.push keyArr[i]
		i++
	if tempArr.length then parenArr.push(tempArr)
	return parenArr

parenCheck = (parenArr) ->
	i = 0
	for arr in parenArr
		if arr[0] in ['(', '[', '{']
			testArr = arr[1...(arr.length - 1)]
		else
			testArr = arr
		for paren in ['(', ')', '[', ']', '{', '}']
			if paren in testArr
				i += arr.indexOf(paren) + 1
				str = ''
				for x in parenArr
					str += x.join('')
				throw new Error "Unexpected \'#{paren}\' at Line #{lineNum}, Colomn #{i}:\n\n\t#{str}\n"
		i += arr.join('').length
	return parenArr

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
	return rebuildArr.join('')

rl.on "line", (line) ->
	lineNum++
	try
		parenCheck parenSplit keyCheck keySplit line
		console.log scoreRebuild keyCheck keySplit line
	catch error
		console.log error
