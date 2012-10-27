require "compass/sass_extensions/sprites/image"

module Compass
  module SassExtensions
    module Sprites
      class Image
        def find_file
          DjangoCompass.resolver("find_sprite", relative_file).to_s
        end
      end
    end
  end
end
