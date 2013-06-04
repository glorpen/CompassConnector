#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
@author: Arkadiusz Dzięgiel

vendor paths:
- used only in compass plugins
- are relative (eg. "image-url(some-image.png)")
absolute paths:
- http://, //, /
- shouldn't be changed
app paths (virtual paths):
- starts with "@"
- using external app/framework to resolve it


get_file(path, type, mode) - zwraca obiekt pliku
	path - virtual path
	type - file type (np. image, css, itp)
	mode - app, vendor

get_url(path, type, mode) - returns object url
	path - virtual path
	typ - file type
	mode - app, vendor

get_configuration: dict
find_sprites(path, mode) - zwraca listę virtualnych ścieżek do plików, eg: sprites/asd/asd @sprites/asdasd

put_file(path, type, data)

tryb absolute nie ma sensu przy find_file a przy get_url ścieżka nie powinna się zmienić

file:
	ext => rozszerzenie pliku (bez kropki)

"""

from __future__ import print_function

from os.path import dirname,realpath,exists,join
import os, sys, re, traceback, base64, hashlib, json
import subprocess

class SimpleResolver(object):
	
	vendor_fonts_dir = "fonts"
	vendor_images_dir = "images"
	vendor_sprites_dir = vendor_images_dir
	
	app_prefix = "/the-app"
	vendor_prefix = "/vendor"
	
	assets_dir = "assets"
	generated_dir = 'generated-images'
	vendor_generated_images_dir = generated_dir
	
	def __init__(self, root):
		super(SimpleResolver, self).__init__()
		self.root = root
	
	def list_vpaths(self, path, vendor):
		pre,post = path.split("*")
		search_path = join(self.root, "vendors", self.vendor_images_dir) if vendor else join(self.root, self.assets_dir)
		return [("" if vendor else "@")+pre+i for i in os.listdir(join(search_path,pre))]
	
	def get_url(self, vpath, vendor, type_):
		if vendor:
			path = self.vendor_prefix+"/"+getattr(self, "vendor_"+type_+"s_dir")+"/"
		else:
			path = self.app_prefix+"/"+(self.generated_dir+"/" if type_ == "generated_image" else "")
			
		return "%s%s" % (path, vpath)
	
	def get_filepath(self, vpath, vendor, type_):
		if vendor:
			path = ["vendors", getattr(self, "vendor_"+type_+"s_dir")]
		else:
			path = [] if type_ == "scss" else [self.assets_dir]
			
		path.append(vpath)
		
		return join(self.root, *path)
	
	def get_out_filepath(self, vpath, type_):
		return join(*([self.root, "out"] + ([self.generated_dir] if type_ == "generated_image" else []) + [vpath]))

class Handler(object):
	
	def __init__(self, root, config={}):
		self.root = root
		
		self.resolver = SimpleResolver(self.root)
		self.config = config
		
	
	def get_configuration(self):
		c = {
			"environment" : ":development",
			"line_comments": True,
			"output_style" : ":expanded", #nested, expanded, compact, compressed
			
			"generated_images_path" : "/",
			"css_path" : "/dev/null",
			"sass_path" : "/dev/null",
		}
		c.update(self.config)
		return c
	
	def file_to_dict(self, filepath):
		filepath = os.path.realpath(filepath)
		
		if not exists(filepath):
			return None
		
		with open(filepath,"rb") as file:
			return {"mtime":os.path.getmtime(filepath), "data": base64.encodebytes(file.read()).decode(), "hash": hashlib.md5(filepath.encode()).hexdigest(), "ext": os.path.splitext(filepath)[1][1:]}
		
	def get_file(self, path, type_, mode):
		
		path = path.lstrip("/")
		
		if type_ in ("generated_image", "out_css"):
			f = self.resolver.get_out_filepath(path, type_)
		else:
			f = self.resolver.get_filepath(path, mode == "vendor", type_)
		
		return self.file_to_dict(f)
	
	def put_file(self, path, type_, data, mode):
		
		if type_  in ("generated_image", "out_css"):
			p = self.resolver.get_out_filepath(path.lstrip("/"), type_)
		else:
			raise NotImplementedError(path, type_)
		
		try:
			os.makedirs(dirname(p))
		except FileExistsError:
			pass
		
		with open(p,"wb") as f:
			f.write(base64.decodebytes(data.encode()))
		return True
	
	def get_url(self, path, type_, mode):
		return self.resolver.get_url(path, mode=="vendor", type_)
	
	def api_version(self):
		return 1
		
	def find_sprites_matching(self, path, mode):
		return tuple(self.resolver.list_vpaths(path, mode=='vendor'))

	def run(self, proc):
		decoder = json.JSONDecoder()
		encoder = json.JSONEncoder()
		bracet = re.compile(br'^(\x1b\x5b[0-9]{1,2}m?)?({.*)$')
		while True:
			line = proc.stdout.readline()
			if not line: break
			
			m = bracet.match(line)
			if m:
				d = decoder.decode(m.group(2).decode())
				print("running %s with: %s" % (d["method"], ", ".join([(a if len(a)<40 else a[0:20]+"...") for a in d["args"]])))
				ret = getattr(self, d["method"])(*d["args"])
				print(ret)
				proc.stdin.write(encoder.encode(ret).encode() + b"\n")
				proc.stdin.flush()
			else:
				sys.stdout.write(line.decode())
				sys.stdout.flush()


if __name__ == "__main__":
	command = ['/home/arkus/.gem/ruby/1.9.1/bin/compass','compile','-r','compass-connector','--trace', sys.argv[1]]
	
	with subprocess.Popen(command,
		cwd = dirname(__file__)+"/cache",
        stdout=subprocess.PIPE,
        stdin=subprocess.PIPE,
        env = {
			"HOME": os.environ["HOME"]
		}) as proc:
		
		h = Handler(root = realpath(dirname(__file__)))
		h.run(proc)
