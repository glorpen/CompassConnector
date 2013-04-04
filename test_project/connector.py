#!/usr/bin/python
# -*- coding: utf-8 -*-

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
	
	public_css = "css/"
	public_images = "images/"
	public_vendors = "vendors/"
	
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
