require 'rubygems'
gem 'json', '>= 1.6.2'
require 'json'

require 'compass'
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
    @api_version = 1
    
    private_class_method
      def self.resolver(method, *args)
        data_in = JSON::dump({'method' => method, 'args' => args})
        STDOUT.puts data_in << "\n"
        STDOUT.flush
        out = STDIN.gets
        ret = JSON::load(out)
        if ret.kind_of?(Hash) and ret.has_key?("error")
          raise "Remote process error: " + ret["error"]
        end
        return ret
      end
    
    def self.get_path_mode(path)
      if path =~ /^@/
        return "app"
      end
      if path =~ %r!^(([a-z0-9]+:/)?/)!
        return "absolute"
      end
      "vendor"
    end
    
    def self.get_mode_and_path(path, required_mode=nil, type=nil)
      mode = self.get_path_mode(path)
      if required_mode and required_mode != mode
        raise "Path mode "+required_mode+" is required for "+path+", "+mode+" detected"
      end
      if mode == "app"
        path = path[1..-1]
      end
      
      return mode, path
    end
    
    def self.get_url(path, type, required_mode=nil)
      mode, path = self.get_mode_and_path(path, required_mode, type)
      
      if mode == "absolute"
        path
      else
        resolver("get_url", path, type, mode)
      end
    end
    
    def self.get_file(path, type, required_mode=nil)
      mode, path = self.get_mode_and_path(path, required_mode, type)
      
      FakeFile.from_response(resolver("get_file", path, type, mode))
    end
      
    def self.find_import(uri)
      
      mode, path = self.get_mode_and_path(uri, "app")
      
      base = File.dirname(path)
      file = File.basename(path, ".scss")
      
      if base == "."
        base = ""
      else
        base += "/"
      end
      
      f = self.get_file("@"+base+file+".scss", "scss", "app")
      #request partial if import not found
      if not f
        f = self.get_file("@"+base+"_"+file+".scss", "scss", "app")
      end
      f
    end
    
    def self.check_api_version()
      v = resolver("api_version")
      if @api_version != v
        raise "Need connector api v#{@api_version}, v#{v or 0} provided"
      end
    end
    
    def self.image_url(path)
      self.get_url(path, "image")
    end
    def self.get_image(path)
      self.get_file(path,"image")
    end
    def self.generated_image_url(path)
      self.get_url(path, "generated_image")
    end
    def self.get_generated_image(path)
      self.get_file(path, "generated_image")
    end
    def self.get_generated_sprite(path)
      path = path.gsub(/^\//, "")
      self.get_file(path, "generated_image")
    end
    def self.find_sprites_matching(uri)
      mode, path = self.get_mode_and_path(uri)
      resolver("find_sprites_matching", path, mode)
    end
    def self.find_sprite(file)
      self.get_file(file, "image")
    end
    def self.get_font(file)
      self.get_file(file, "font")
    end
    def self.font_url(path)
      self.get_url(path, "font")
    end
    def self.stylesheet_url(path)
      self.get_url(path, "css")
    end
    def self.put_sprite(filename, f)
      filename = filename.gsub(/^\//, "")
      mode, path = self.get_mode_and_path(filename)
      resolver("put_file", path, "generated_image", Base64.encode64(f.read), mode)
    end
    def self.put_output_css(filename, data)
      mode, path = self.get_mode_and_path(filename,"app")
      resolver("put_file", path, "out_css", Base64.encode64(data), mode)
    end
    def self.get_output_css(filename)
      self.get_file(filename, "out_css", "app")
    end
    
    def self.configuration()
      self.check_api_version()
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
