require 'compass'
require 'yaml'
require "shellwords"

class DjangoCompass
  
  def self.resolver(method, *args)
    cmd = "python -m djangocompass.ruby_resolver "+method
    args.each do |i|
      cmd += " "+Shellwords.escape(i)
    end
    return YAML::load(`#{cmd}`)
  end
  
  class Importer < Sass::Importers::Base
    def to_s()
      "DjangoCompass::Importer"
    end
    
    def find(uri, options)
      f = DjangoCompass.resolver("find_scss", uri)
      
      if f
        f = f.to_s
        syntax = (f =~ /\.(s[ac]ss)$/) && $1.to_sym || :sass
        opts = options.merge(:syntax => syntax, :importer => self, :filename => f)
        return Sass::Engine.new(open(f).read, opts)
      end
      
      nil
    end
    
    def find_relative(uri, base, options)
      nil
    end
    
    def mtime(name, options)
      file, s = find_real_file(name)
      File.mtime(file) if file
    rescue Errno::ENOENT
      nil
    end
    
    def key(name, options)
      [self.class.name + ":" + File.dirname(File.expand_path(name)),
        File.basename(name)]
    end
  end
end

require 'django-compass/patches/compiler'
require 'django-compass/patches/urls'
require 'django-compass/patches/sprite_image'
require 'django-compass/patches/sprite_map'
require 'django-compass/patches/sprite_importer'
require 'django-compass/patches/watch_project'
