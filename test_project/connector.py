#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
set loaded vendor paths from ruby env? //nope
without "private" folder - just single / is for app and without is for vendors
"""

import sys, simplejson
from os.path import dirname,realpath,exists,join
import os
import re
import traceback

root = realpath(dirname(__file__))

re_schema = re.compile(r'^(([a-z0-9]+://)|(//))')

def detect_vendor(allow_absolute=True):
	
	def decorator(fun):
		def wrapper(self, path):
			absolute = re_schema.match(path) is not None
			if absolute:
				if not allow_absolute:
					raise Exception()
				else:
					return path
			vendor = not absolute and not path.startswith("/")
			return fun(self, path, vendor)
		return wrapper
	
	return decorator

class Handler(object):
	
	scss_root = join(root,"scss")
	images_root = join(root,"images")
	fonts_root = join(root,"fonts")
	vendors_root = join(root,"vendors")
	
	out_generated_images_root = join(root,"out","generated-images")
	out_stylesheets_root = join(root,"out","css")
	
	public_fonts = "/fonts/"
	public_css = "/css/"
	public_images = "/images/"
	public_vendors = "/vendors/"
	public_generated_images = "/generated-images/"
	
	#TODO collect file paths and mtimes
	
	def get_configuration(self):
		return {
			"environment" : ":development",
			"line_comments": True,
			"output_style" : ":expanded", #nested, expanded, compact, compressed
			
			"generated_images_path" : self.out_generated_images_root,
			"css_path" : self.out_stylesheets_root,
			
			"http_path" : "/",
			"relative_assets": False
		}
	
	def list_main_files(self):
		"""
		list main scss files (which are compiled to own css)
		"""
		ret = []
		for i in os.listdir(self.scss_root):
			if not i.startswith("_") and i.endswith(".scss"):
				ret.append(i)
		return ret
	
	def find_scss(self, path):
		"""
		return full path for scss
		"""
		base, file = os.path.split(path)
		
		#maybe from @import - without extension
		if not file.endswith(".scss"):
			file+=".scss"
		
		#check if file exists
		f = join(self.scss_root, base, file)
		#if not, try with underscore
		return f if exists(f) else join(self.scss_root, base, "_"+file)
	
	@detect_vendor(True)
	def get_image_url(self, path, vendor):
		if vendor:
			return self.public_vendors + "images/" + path
		else:
			return self.public_images + path[1:]
	
	@detect_vendor(False)
	def find_image(self, path, vendor):
		if vendor:
			return join(self.vendors_root, "images", path)
		else:
			return self.images_root + path
			
	
	def find_generated_image(self, path):
		return join(self.out_generated_images_root, path.lstrip("/"))
	
	@detect_vendor(True)
	def get_generated_image_url(self, path, vendor):
		#all generated images will end up in our path
		return self.public_generated_images + path.lstrip("/")
	
	def find_sprites_matching(self, path):
		pre,post = path.split("*")
		return [pre+i for i in os.listdir(join(realpath(dirname(__file__)),pre[1:]))]
	def find_sprite(self, path):
		return join(realpath(dirname(__file__)),path[1:])
	
	@detect_vendor(True)
	def get_font_url(self, path, vendor):
		if vendor:
			return join(self.public_vendors, "fonts", path)
		else:
			return self.public_fonts + path
	
	@detect_vendor(False)
	def find_font(self, path, vendor):
		if vendor:
			return join(self.vendors_root, "fonts", path)
		else:
			return join(self.fonts_root, path.lstrip("/"))
	
	@detect_vendor(True)
	def get_stylesheet_url(self, path, vendor):
		if vendor:
			return self.public_vendors + "css/" + path
		else:
			return self.public_css + path.lstrip("/")
	

h = Handler()

if len(sys.argv)>1:
	print getattr(h, sys.argv[1])(*sys.argv[2:])
else:
	decoder = simplejson.JSONDecoder()
	encoder = simplejson.JSONEncoder()
	while True:
		line = sys.stdin.readline()
		if line == "":
			break
		try:
			d = decoder.decode(line)
			ret = getattr(h, d["method"])(*d["args"])
			sys.stdout.write(encoder.encode(ret) + "\n")
		except Exception as e:
			sys.stdout.write(encoder.encode({"error":traceback.format_exc()}) + "\n")
		finally:
			sys.stdout.flush()
