require 'compass'

Compass::Configuration.add_configuration_property(:django_settings, "this is a foobar")
Compass::Configuration.add_configuration_property(:virtual_env, "this is a foobar")

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
      f = DjangoCompass.resolver.find_scss(uri+".scss")
      f = DjangoCompass.resolver.find_scss("_"+uri+".scss")
      
      f = f.to_s
      
      syntax = (f =~ /\.(s[ac]ss)$/) && $1.to_sym || :sass
      opts = options.merge(:syntax => syntax)
      return Sass::Engine.new(open(f.to_s).read, opts)
    end
  end
end

#require 'django-compass/patches/importer'
require 'django-compass/patches/compiler'
require 'django-compass/patches/urls'
require 'django-compass/patches/sprite_image'
require 'django-compass/patches/sprite_map'
require 'django-compass/patches/sprite_importer'
#require 'django-compass/patches/3_1'