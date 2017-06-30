#!/usr/bin/env coffee
#-*- coding: utf-8 -*-

# Filename: tokenizer.coffee
# Created by 请叫我喵 Alynx.
# alynx.zhou@gmail.com, http://alynx.xyz/

fs = require("fs")
path = require("path")
readline = require("readline")
commander = require("commander")

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
  commander.move = valueSeq.indexOf(commander.from) - \
                   valueSeq.indexOf(commander.to)


NOT_COMMENT = 0
SINGLE_COMMENT = 1
MULTI_COMMENT = 2

class Converter
  constructor: () ->
    @validArr = [' ', '\r', '\n', '\t', '|',
                 '(', ')', '{', '}', '[', ']', '<', '>',
                 '0', '1', '2', '3', '4', '5', '6', '7',
                 '#1', '#2', '#3', '#4', '#5', '#6', '#7']
    @keySeq = ['(1)', '(#1)', '(2)', '(#2)', '(3)', '(4)',
              '(#4)', '(5)', '(#5)', '(6)', '(#6)', '(7)',
              '1', '#1', '2', '#2', '3', '4', '#4', '5', '#5', '6', '#6', '7',
              '[1]', '[#1]', '[2]', '[#2]', '[3]', '[4]', \
              '[#4]', '[5]', '[#5]', '[6]', '[#6]', '[7]',
              '{1}', '{#1}', '{2}', '{#2}', '{3}', '{4}', \
              '{#4}', '{5}', '{#5}', '{6}', '{#6}', '{7}']
    @digits = ['1', '2', '3', '4', '5', '6', '7']
    @digitsNotes = JSON.parse(
      fs.readFileSync(path.join(__dirname, "digits-notes.json"))
    )
    @line = ''
    @lineNum = 0
    @bracketObject =
      '(': ')'
      '[': ']'
      '{': '}'
    @bracketStatus = ''
    @commentStatus = NOT_COMMENT
    @consoleMode = false
    @tokenCollector = []

  tokenSplit: () =>
    i = 0
    while i < @line.length
      switch @commentStatus
        when SINGLE_COMMENT
          @tokenCollector[@tokenCollector.length - 1] += @line.charAt(i)
          if @line.charAt(i) is '\n' or i is @line.length - 1
            @commentStatus = NOT_COMMENT
          i++
          continue
        when MULTI_COMMENT
          @tokenCollector[@tokenCollector.length - 1] += @line.charAt(i)
          if @line.charAt(i) is '*' and @line.charAt(i + 1) is ';'
            @tokenCollector[@tokenCollector.length - 1] += @line.charAt(++i)
            @commentStatus = NOT_COMMENT
          i++
          continue
      if @bracketStatus of @bracketObject
        if @line.charAt(i) in @digits
          @tokenCollector.push(@bracketStatus + @line.charAt(i) + \
                              @bracketObject[@bracketStatus])
        else if @line.charAt(i) is '#' and @line.charAt(i + 1) in @digits
          @tokenCollector.push(@bracketStatus + @line.charAt(i) + \
                              @line.charAt(++i) + \
                              @bracketObject[@bracketStatus])
        else if @line.charAt(i) is ';' and @line.charAt(i + 1) is ';'
          @tokenCollector.push(@line.charAt(i) + @line.charAt(++i))
          @commentStatus = SINGLE_COMMENT
        else if @line.charAt(i) is ';' and @line.charAt(i + 1) is '*'
          @tokenCollector.push(@line.charAt(i) + @line.charAt(++i))
          @commentStatus = MULTI_COMMENT
        else if @line.charAt(i) is '\n'
          @tokenCollector.push(@line.charAt(i))
        else if @line.charAt(i) is @bracketObject[@bracketStatus]
          @bracketStatus = ''
        else
          throw new Error("Error: Invalid character.")
      else
        if @line.charAt(i) in @digits
          @tokenCollector.push(@line.charAt(i))
        else if @line.charAt(i) is '#' and @line.charAt(i + 1) in @digits
          @tokenCollector.push(@line.charAt(i) + @line.charAt(++i))
        else if @line.charAt(i) of @bracketObject
          @bracketStatus = @line.charAt(i)
        else if @line.charAt(i) is ';' and @line.charAt(i + 1) is ';'
          @tokenCollector.push(@line.charAt(i) + @line.charAt(++i))
          @commentStatus = SINGLE_COMMENT
        else if @line.charAt(i) is ';' and @line.charAt(i + 1) is '*'
          if not @consoleMode
            @tokenCollector.push(@line.charAt(i) + @line.charAt(++i))
            @commentStatus = MULTI_COMMENT
          else
            throw new Error("Error: Cannot support multi@line \
                             comment in console mode.")
        else if @line.charAt(i) is '\n'
          @tokenCollector.push(@line.charAt(i))
        else
          throw new Error("Error: Invalid character.")
      i++

  fixKey: () =>
    i = 0
    while i < @tokenCollector.length
      switch @tokenCollector[i]
        when '(#3)' then @tokenCollector[i] = '(4)'
        when '(#7)' then @tokenCollector[i] = '1'
        when '#3' then @tokenCollector[i] = '4'
        when '#7' then @tokenCollector[i] = '[1]'
        when '[#3]' then @tokenCollector[i] = '[4]'
        when '[#7]' then @tokenCollector[i] = '{1}'
        when '{#3}' then @tokenCollector[i] = '{4}'
      i++

  moveKey: (moveStep) =>
    i = 0
    while i < @tokenCollector.length
      if @keySeq.indexOf(@tokenCollector[i]) isnt -1
        if @keySeq.indexOf(@tokenCollector[i]) + moveStep \
           in [0...@keySeq.length]
          @tokenCollector[i] = @keySeq[@keySeq.indexOf(@tokenCollector[i]) + \
                                       moveStep]
        else
          throw new Error("Error: Cannot move #{@tokenCollector[i]} \
                           with #{moveStep} steps.")
      i++

  printSheet: () =>
    console.log(@tokenCollector.join(''))

  console: () =>
    # @consoleMode = true
    @rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    })
    @rl.setPrompt("==> ")
    @rl.prompt()
    @rl.on("line", (@line) =>
      # @line += '\n'
      @tokenSplit()
      @fixKey()
      if commander.move? and commander.move isnt 0
        @moveKey(commander.move)
      if @commentStatus isnt MULTI_COMMENT
        @printSheet()
        @rl.setPrompt("==> ")
        @tokenCollector = []
      else
        @rl.setPrompt("--> ")
      @rl.prompt()
    )
    @rl.on("close", ->
      # @consoleMode = false
      @rl.close()
      process.exit(0)
    )

new Converter().console()
