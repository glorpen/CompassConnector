require 'compass'

require 'json'
require 'base64'

require 'compass-connector/importer'

module CompassConnector

  class FakeFile < File
    def initialize(data)
      path = "/tmp/"+data["hash"]+"."+data["ext"]
      super path, "w+b"
      write(Base64.decode64(data["data"]))
      rewind()
      File.utime(Time.new, Time.at(data["mtime"]), path)
    end
    
    def self.from_response(response)
      if response
        FakeFile.new(response)
      end
    end
    
  end
  
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
        #$stdout.puts "Process input: " + data_in
        @process << data_in << "\n"
        out = @process.gets
        #$stdout.puts "Process output: " + out
        ret = JSON::load(out)
        if ret.kind_of?(Hash) and ret.has_key?("error")
          raise "Remote process error: " + ret["error"]
        end
        return ret
      end
    
    
    def self.find_import(uri)
      FakeFile.from_response(resolver("find_import", uri))
    end
    def self.image_url(path)
      resolver("get_image_url", path)
    end
    def self.get_image(path)
      FakeFile.from_response(resolver("get_file", path, "image"))
    end
    def self.generated_image_url(path)
      resolver("get_generated_image_url", path)
    end
    def self.get_generated_image(path)
      FakeFile.from_response(resolver("get_file", path, "generated_image"))
    end
    def self.find_sprites_matching(uri)
      resolver("find_sprites_matching", uri)
    end
    def self.find_sprite(file)
      FakeFile.from_response(resolver("get_file", file, "sprite"))
    end
    def self.get_font(path)
      FakeFile.from_response(resolver("get_file", path, "font"))
    end
    def self.font_url(path)
      resolver("get_font_url", path)
    end
    def self.stylesheet_url(path)
      resolver("get_stylesheet_url", path)
    end
    def self.put_sprite(filename, f)
      resolver("put_file", filename, "sprite", Base64.encode64(f.read))
    end
    def self.put_output_css(filename, data)
      resolver("put_file", filename, "css", Base64.encode64(data))
    end
    def self.get_output_css(filename)
      FakeFile.from_response(resolver("get_file", filename, "out_stylesheet"))
    end
    
    def self.configuration()
      resolver("get_configuration")
    end
  
  end

end

require 'compass-connector/configuration'
require 'compass-connector/patches/actions'
require 'compass-connector/patches/compiler'
require 'compass-connector/patches/urls'
require 'compass-connector/patches/sprite_image'
require 'compass-connector/patches/sprite_map'
require 'compass-connector/patches/sprite_methods'
require 'compass-connector/patches/sprite_importer'
require 'compass-connector/patches/image_size'
require 'compass-connector/patches/inline_images'
