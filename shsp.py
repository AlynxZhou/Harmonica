#!/usr/bin/env python3
#-*- coding: utf-8 -*-

import re
import argparse

## Get args.
aparser = argparse.ArgumentParser(description="Replace sheet spaces.")
aparser.add_argument("sheet", action="store", type=str, help="The heet file.")
args = aparser.parse_args()

new_file = args.sheet.split('.', 1)[0] + "_new." + args.sheet.split('.', 1)[1]
print(new_file)
SHEET_REGEX = re.compile(r'[\(\[\{](?:[#1-7]*(\s+)[#1-7]*)+[\)\]\}]')

# reg.search(a).group(0).replace(' ', ") (")

with open(args.sheet, 'r') as origin, open(new_file, 'w') as new:
    for line in origin.readlines():
        line_dict = re.split(SHEET_REGEX, line)
