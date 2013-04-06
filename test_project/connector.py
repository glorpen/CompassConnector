#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
set loaded vendor paths from ruby env? //nope
without "private" folder - just single / is for app and without is for vendors
"""

import sys, simplejson
from os.path import dirname,realpath,exists,join
import os

"""
fonty tylko w public,
images mogą być w public i ukrytym
"""

class Handler(object):
	
	scss_root = realpath(dirname(__file__))+"/scss"
	images_root = realpath(dirname(__file__))+"/images"
	vendors_root = realpath(dirname(__file__))+"/vendor"
	
	public_fonts = "fonts/"
	public_css = "css/"
	public_images = "images/"
	public_vendors = "vendors/"
	
	#TODO collect file paths and mtimes
	
	def get_configuration(self):
		return {
			"environment" : ":development",
			"line_comments": True,
			"output_style" : ":expanded", #nested, expanded, compact, compressed
			
			"generated_images_path" : "out/generated-images", #disk path
			"css_path" : "out/css",
			
			"http_path" : "/",
			"relative_assets": False
		}
	
	#list main scss files (which are compiled to own css)
	def list_main_files(self):
		ret = []
		for i in os.listdir(self.scss_root):
			if not i.startswith("_") and i.endswith(".scss"):
				ret.append(i)
		return ret
	
	#return real path for scss (?)
	def find_scss(self, path):
		base, file = os.path.split(path)
		
		#maybe from @import - without extension
		if not file.endswith(".scss"):
			file+=".scss"
		
		#check if file exists
		f = join(self.scss_root, base, file)
		#if not, try with underscore
		return f if exists(f) else join(self.scss_root, base, "_"+file)
	
	def image_url(self, path):
		if path.startswith("http://") or path.startswith("https://") or path.startswith("//"):
			return path
		if path.startswith("/"):
			# image from your app
			return self.public_images + path[1:]
		else:
			#probably from vendors
			#you should mount vendor assets under some path
			return self.public_vendors + path
	
	def find_image(self, path):
		if path.startswith("/"):
			return self.images_root + path
		else: #vendor
			#TODO: self.public_vendors
			return self.images_root + "/" + path.split("/")[1]
	
	def find_generated_image(self, path):
		return path
	
	def generated_image_url(self, path):
		return "/asd/" + path
	
	def find_sprites_matching(self, path):
		pre,post = path.split("*")
		return [pre+i for i in os.listdir(join(realpath(dirname(__file__)),pre[1:]))]
	
	def find_sprite(self, path):
		return join(realpath(dirname(__file__)),path[1:])
	def font_url(self, path):
		"""
		@return: virtual path for font
		"""
		return self.public_fonts + path
	def find_font(self, path):
		"""
		@return: real path for font file
		"""
		return join(realpath(dirname(__file__)),'fonts', path)
	
	def stylesheet_url(self, path):
		"""
		@return: just virtual path
		"""
		return path
	

h = Handler()

if len(sys.argv)>1:
	print getattr(h, sys.argv[1])(*sys.argv[2:])
else:
	while True:
		line = sys.stdin.readline()
		if line == "":
			break
		d = simplejson.JSONDecoder().decode(line)
		ret = getattr(h, d["method"])(*d["args"])
		sys.stdout.write(simplejson.JSONEncoder().encode(ret) + "\n")
		sys.stdout.flush()
