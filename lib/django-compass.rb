require 'compass'
require 'json'

require 'django-compass/importer'
require 'django-compass/configuration'

extension_path = File.expand_path(File.join(File.dirname(__FILE__), ".."))
Compass::Frameworks.register('my_extension', :path => extension_path)

module CompassConnector

  class Resolver
    
    @process = nil
    
    private_class_method
      def self.resolver(method, *args)
        if @process == nil
          cmd = ENV["COMPASS_CONNECTOR"]
          if cmd == nil
            raise Compass::Error, "You have to define COMPASS_CONNECTOR env variable"
          end
          @process = IO.popen(cmd, "r+")
        end
        
        data_in = JSON::dump({'method' => method, 'args' => args})
        print "Process input: ", data_in, "\n"
        @process << data_in << "\n"
        out = @process.gets
        print "Process output: ", out
        return JSON::load(out)
      end
    
    
    def self.find_scss(uri)
      resolver("find_scss", uri)
    end
    def self.list_main_files()
      resolver("list_main_files")
    end
    def self.image_url(path)
      resolver("image_url", path)
    end
    def self.find_image(path)
      resolver("find_image", path)
    end
  
  end

end

require 'django-compass/patches/compiler'
require 'django-compass/patches/urls'
require 'django-compass/patches/sprite_image'
require 'django-compass/patches/sprite_map'
require 'django-compass/patches/sprite_importer'
require 'django-compass/patches/image_size'
require 'django-compass/patches/inline_images'
require 'django-compass/patches/watch_project'