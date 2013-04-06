require 'compass'
require 'json'

require 'django-compass/importer'

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
    def self.generated_image_url(path)
      resolver("generated_image_url", path)
    end
    def self.find_generated_image(path)
      resolver("find_generated_image", path)
    end
    def self.find_sprites_matching(uri)
      resolver("find_sprites_matching", uri)
    end
    def self.find_sprite(file)
      resolver("find_sprite", file)
    end
    def self.find_font(path)
      resolver("find_font", path)
    end
    def self.font_url(path)
      resolver("font_url", path)
    end
    def self.stylesheet_url(path)
      resolver("stylesheet_url", path)
    end
    
    def self.configuration()
      resolver("get_configuration")
    end
  
  end

end

require 'django-compass/configuration'
require 'django-compass/patches/compiler'
require 'django-compass/patches/urls'
require 'django-compass/patches/sprite_image'
require 'django-compass/patches/sprite_map'
require 'django-compass/patches/sprite_importer'
require 'django-compass/patches/image_size'
require 'django-compass/patches/inline_images'
