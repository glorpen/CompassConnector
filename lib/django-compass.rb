require 'compass'

class DjangoCompass
  def self.find_asset(path)
    require 'rubypython'
    RubyPython.start_from_virtualenv("/mnt/sandbox/workspace/kia/env")
    resolver = RubyPython.import("djangocompass.ruby_resolver")
    p resolver.find(path)
    RubyPython.stop
  end
  
  class Importer
  end
end

require 'django-compass/patches/importer'
require 'django-compass/patches/urls'
#require 'django-compass/patches/3_1'