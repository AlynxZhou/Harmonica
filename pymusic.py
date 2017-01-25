#!/usr/bin/env python3
#-*- coding: utf-8 -*-

### Filename: pymusic.py
## Created by 请叫我喵 Alynx.
# sxshax@gmail.com, http://alynx.xyz/

import time
import random
import hashlib
import argparse

from tkinter import *
from tkinter.font import Font, BOLD
from tkinter.messagebox import showinfo
from tkinter.scrolledtext import ScrolledText

__version__ = "0.3.0"
__author__ = "请叫我喵 Alynx"

conv_dict = {
	'!': "#1",
	'@': "#2",
	'#': "#3",
	'$': "#4",
	'%': "#5",
	'^': "#6",
	'&': "#7",
}

class Application(Tk):
	"""
	主要的窗口程序，直接继承 tkinter 底层的 Tk 类构建。
	"""
	def __init__(self, master=None):
		"""
		窗口生成时的必要准备。
		"""
		super(Application, self).__init__(master)
		self.title("PyMusic Ver %s by %s"%(__version__, __author__))
		# 设置窗口的大小。
		t = self.winfo_screenwidth() // 800
		self.geometry("%dx%d"%(400 * t, 250 * t))
		# 设置窗口尺寸是否可调。
		self.resizable(width=True, height=True)
		self.update()
		# print(self.winfo_width())
		# 自定义一个字体对象。
		self.font = Font(self, family="Monospace", size=4 * t, weight=BOLD)
		# .grid() 布局方式对行或列占据比例的设置，weight 的总值为分母，单个 weight 的值为分子, minsize 为最小宽度。
		self.rowconfigure(0, weight=1, minsize=int(250 * t * 2 / 5))
		self.rowconfigure(1, weight=1, minsize=int(250 * t / 5))
		self.rowconfigure(2, weight=1, minsize=int(250 * t * 2 / 5))
		self.columnconfigure(0, weight=1)
		# 建立自己定义的对象并解析参数。
		self.create_input()
		self.create_button()
		self.create_output()

	def create_input(self):
		"""
		建立输入乐谱的文本框。
		"""
		self.input_frame = Frame(self)
		# 提示语，隶属于第一个 Frame，展示在这个 Frame 的第一行。
		Label(self.input_frame,\
		      text="在这里输入：",\
		      font=self.font).grid(row=0, column=0, sticky='w')
		# 建立隶属于第一个 Frame 的文本框对象，用于后续获取文本。
		self.input = ScrolledText(self.input_frame,\
						 font=self.font,\
						#  width=self.winfo_width() - 200,\
						#  height=self.winfo_height() * 2 // 5 - 30,\
						 fg="DarkSlateGray")
		# 在 Frame 的第二行展示。
		self.input.grid(row=1, column=0)
		self.input_frame.grid(row=0, column=0)

	def create_button(self):
		"""
		建立一个转换按钮。
		"""
		# 绑定回车作为执行键（有问题）。
		# self.input.bind(sequence="<Enter>", func=self.convent)
		# 建立确定按钮，点击后执行 convent() 方法开启对战。
		self.conv_button = Button(self, text="转换",\
					  state="normal",\
					  command=self.convent,\
					  font=self.font,\
					  fg="red")
		self.conv_button.grid(row=1, column=0)

	def create_output(self):
		"""
		用于输出处理后的乐谱。
		"""
		self.output_frame = Frame(self)
		Label(self.output_frame,\
			  text="这里会输出：",\
			  font=self.font).grid(row=0, column=0, sticky='w')
		self.output = ScrolledText(self.output_frame,\
						 font=self.font,\
						#  width=self.winfo_width() - 200,\
						#  height=self.winfo_height() * 2 // 5 - 30,\
						 fg="DarkSlateGray")
		self.output.grid(row=1, column=0)
		self.output_frame.grid(row=2, column=0)
		# self.name_input2.bind(sequence="<Enter>", func=self.callback)

	def convent(self):
		strings = self.input.get(0.0, END)
		for char in strings:
			if char in conv_dict.keys():
				self.output.insert(END, conv_dict[char])
			else:
				self.output.insert(END, char)
			# 实时更新显示内容。
			self.output.update()
			# 自动滚动到文本末尾。
			self.output.see(END)

# 运行。
if __name__ == "__main__":
	root = Application()
	# 启动程序主循环
	root.mainloop()
