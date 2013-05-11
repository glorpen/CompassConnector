#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, simplejson
from os.path import dirname,realpath,exists,join
import os
import re
import traceback
import base64
import hashlib

root = realpath(dirname(__file__))

re_schema = re.compile(r'^(([a-z0-9]+://)|(//))')

"""
check why @import reads file from current dir if matches
remove CWD dependency in single_file mode - in cmdline sass files should be absolute paths
"""

def detect_vendor(allow_absolute=True):
	
	def decorator(fun):
		def wrapper(self, path, *args):
			absolute = re_schema.match(path) is not None
			if absolute:
				if not allow_absolute:
					raise Exception()
				else:
					return path
			vendor = not absolute and not path.startswith("/")
			args = list(args)
			args.append(vendor)
			return fun(self, path, *args)
		return wrapper
	
	return decorator

class Handler(object):
	
	scss_root = join(root,"scss")
	images_root = join(root,"images")
	fonts_root = join(root,"fonts")
	vendors_root = join(root,"vendors")
	sprites_root = root
	
	generated_images_root = join(root,"out","generated-images")
	out_stylesheets_root = join(root,"out","css")
	
	public_fonts = "/fonts/"
	public_css = "/css/"
	public_images = "/images/"
	public_vendors = "/vendors/"
	public_generated_images = "/generated-images/"
	
	def get_configuration(self):
		return {
			"environment" : ":development",
			"line_comments": True,
			"output_style" : ":expanded", #nested, expanded, compact, compressed
			
			"generated_images_path" : "/",
			"css_path" : "/dev/null",
			"sass_path" : "/dev/null",
		}
	
	def file_to_dict(self, filepath):
		filepath = os.path.realpath(filepath)
		
		if not exists(filepath):
			return None
		
		with open(filepath,"rb") as file:
			return {"mtime":os.path.getmtime(filepath), "data": base64.encodestring(file.read()), "hash":hashlib.md5(filepath).hexdigest(), "ext": os.path.splitext(filepath)[1][1:]}
		
	def find_import(self, path):
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
		f = f if exists(f) else join(self.scss_root, base, "_"+file)
		
		return self.file_to_dict(f)
	
	@detect_vendor(True)
	def get_image_url(self, path, vendor):
		if vendor:
			return self.public_vendors + "images/" + path
		else:
			return self.public_images + path[1:]
	
	@detect_vendor(True)
	def get_file(self, path, type_, vendor):
		
		path = path.lstrip("/")
		
		if vendor and not type_ in ("generated_image", "out_stylesheet"):
			f = join(self.vendors_root, type_+"s", path)
		else:
			f = join(getattr(self, type_+"s_root"), path)
		
		if type_ == "output_css":
			raise Exception("asd")
		
		return self.file_to_dict(f)
	
	def put_file(self, path, type_, data):
		
		if type_  == "sprite":
			p = join(self.generated_images_root, path.lstrip("/"))
		elif type_  == "css":
			p = join(self.out_stylesheets_root, path.lstrip("/"))
		else:
			raise Exception(path, type_)
		
		with open(p,"wb") as f:
			f.write(base64.decodestring(data))
		return True
	
	@detect_vendor(True)
	def get_generated_image_url(self, path, vendor):
		#all generated images will end up in our path
		return self.public_generated_images + path.lstrip("/")
	
	def find_sprites_matching(self, path):
		pre,post = path.split("*")
		return [pre+i for i in os.listdir(join(realpath(dirname(__file__)),pre[1:]))]
	
	@detect_vendor(True)
	def get_font_url(self, path, vendor):
		if vendor:
			return join(self.public_vendors, "fonts", path)
		else:
			return self.public_fonts + path
	
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
