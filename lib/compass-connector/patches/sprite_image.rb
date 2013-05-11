require "compass/sass_extensions/sprites/image"

module Compass
  module SassExtensions
    module Sprites
      class Image
        def find_file
          CompassConnector::Resolver.find_sprite(relative_file)
        end
      end
    end
  end
end
