require 'compass'

class DjangoCompass
  
  def self.resolver
    if defined? @resolver
      return @resolver
    end
    
    require 'rubypython'
    RubyPython.start()
    
    #initialize app
    settings = RubyPython.import(ENV["DJANGO_SETTINGS_MODULE"])
    @resolver = RubyPython.import("djangocompass.ruby_resolver").resolver
    #RubyPython.stop
    
  end
  
  class Importer < Sass::Importers::Base
    def to_s()
      "DjangoCompass::Importer"
    end
    def find(uri, options)
      f = DjangoCompass.resolver.find_scss(uri)
      
      if f
        f = f.to_s
        syntax = (f =~ /\.(s[ac]ss)$/) && $1.to_sym || :sass
        opts = options.merge(:syntax => syntax)
        return Sass::Engine.new(open(f).read, opts)
      end
      
      nil
    end
    def find_relative(uri, base, options)
      nil
    end
    def mtime(uri, options)
      nil
    end
  end
end

require 'django-compass/patches/compiler'
require 'django-compass/patches/urls'
require 'django-compass/patches/sprite_image'
require 'django-compass/patches/sprite_map'
require 'django-compass/patches/sprite_importer'
require 'django-compass/patches/watch_project'
