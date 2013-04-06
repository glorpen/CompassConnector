require 'compass'

module CompassConnector
  
  class Importer < Sass::Importers::Base
    def to_s()
      "CompassConnector::Importer"
    end
    
    def find(uri, options)
      f = CompassConnector::Resolver.find_scss(uri)
      
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
