require 'compass'

module CompassConnector
  
  class Importer < Sass::Importers::Base
    def to_s()
      "CompassConnector::Importer"
    end
    
    def find(uri, options)
      f = CompassConnector::Resolver.find_import(uri)
      
      if f
        opts = options.merge(:syntax => :scss, :importer => self, :filename => uri)
        return Sass::Engine.new(f.read, opts)
      end
      
      nil
    end
    
    def find_relative(uri, base, options)
      nil
    end
    
    def mtime(name, options)
      nil
    end
    
    def key(name, options)
      [self.class.name + ":" + File.dirname(File.expand_path(name)),
        File.basename(name)]
    end
  end
  
end
