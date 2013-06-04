require "compass/sass_extensions/sprites/sprite_methods"
require "tempfile"

module Compass
  module SassExtensions
    module Sprites
      module SpriteMethods
        
        def tmp_filename
          fname = File.join(Compass.configuration.generated_images_path, name_and_hash)
          f = CompassConnector::Resolver.get_generated_sprite(fname)
          f && f.to_path || nil
        end
        
        def generation_required?
          !(tmp_filename && File.exists?(tmp_filename)) || outdated?
        end
        
        def outdated?
          if tmp_filename && File.exists?(tmp_filename)
            return @images.any? {|image|
              image.mtime.to_i > self.mtime.to_i
          }
          end
          true
        end
        
        def mtime
          @mtime ||= File.mtime(tmp_filename)
        end
        
        def save!
          f=Tempfile.new("sprite")
          engine.save(f.to_path)
          f.rewind
          saved = CompassConnector::Resolver.put_sprite(filename, f)
          f.close!
          
          #saved = true engine.save(filename)
          log :create, filename
          Compass.configuration.run_sprite_saved(filename)
          @mtime = nil if saved
          saved
        end
        
      end
    end
  end
end
