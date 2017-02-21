#!/usr/bin/env python3
#-*- coding: utf-8 -*-

class NotMusicError(ValueError):
    pass

class Interpreter:
    def __init__(self, note):
        self._note = note

    def score_encode(self):
        with open(self._note, 'r') as note_open:
            for line in note_open.readlines():
                for char in line:




def change():
    line = input("Music > ")
    line += '\n'
    comp_dict = {
        '1': '!',
        '2': '@',
        '3': '#',
        '4': '$',
        '5': '%',
        '6': '^',
        '7': '&'
    }
    valid_list = [' ', '\n', '#', '(', ')', '{', '}', '[', ']', '<', '>', '0', '1', '2', '3', '4', '5', '6', '7']
    for char in line:
        if not char in valid_list:
            raise NotMusicError("Invalid music note \'%s\'."%(char))
    i = 0
    while i < len(line):
        if line[i] == '#':
            if line[i + 1] in comp_dict:
                print(comp_dict[line[i + 1]], end='')
                i += 1
            else:
                raise NotMusicError("Invalid express \'#%s\'."%(line[i + 1]))
        else:
            print(line[i], end='')
        i += 1
